import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_l10n/modoo_l10n.dart';
import 'package:modoo_reader_engine/modoo_reader_engine.dart';
import 'package:modoo_ui/modoo_ui.dart';

import '../../providers/app_providers.dart';
import 'reading_session_recorder.dart';

/// Paginated reader.
///
/// Pages are character ranges measured with `TextPainter` (packages/ui) and
/// cached per `layoutHash` (DEVELOPMENT_PLAN §3.5.3). Positions are saved as
/// `(chapterIndex, charOffset)` so changing the font size never loses the
/// reader's place.
class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({
    super.key,
    required this.bookId,
    this.minimumSession = const Duration(seconds: 5),
  });

  final int bookId;

  /// Sessions shorter than this are not recorded, so a glance at a book does
  /// not become a row in the statistics.
  final Duration minimumSession;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> with SingleTickerProviderStateMixin {
  static const double _verticalPadding = 20;

  /// Hair of tracking keeps CJK punctuation from touching the next glyph.
  static const double _letterSpacing = 0.2;

  final PageController _pageController = PageController();

  List<Chapter> _chapters = const <Chapter>[];
  List<PageSpan> _pages = const <PageSpan>[];
  int _chapterIndex = 0;
  int _pageIndex = 0;
  int _restoredOffset = -1;
  bool _restored = false;
  bool _paginating = false;
  bool _paginateScheduled = false;
  Timer? _prefetchTimer;
  String? _paginateError;
  int _paginateToken = 0;
  int _layoutHash = 0;
  Size _contentSize = Size.zero;
  String _cacheKey = '';

  /// Whole book text; needed to slice the next chapter for prefetching.
  String _fullText = '';

  /// Owning scaffold, so the drawer button and the table of contents can open
  /// the left drawer without a `Builder` in between.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Tomato-style immersive reading: the top and bottom chrome are hidden by
  /// default and a tap in the middle of the page toggles them.
  bool _chromeVisible = false;

  /// Where the current tap started; used to tell taps from page swipes.
  Offset? _tapOrigin;
  static const double _tapSlop = 8;

  /// Live pointers, so a two-finger pinch can resize the text.
  ///
  /// Tracked at the pointer level rather than through `GestureDetector`:
  /// `PageView` and `SelectionArea` already compete in the gesture arena, and a
  /// pinch recognizer would lose to the horizontal drag.
  final Map<int, Offset> _pointers = <int, Offset>{};
  double? _pinchStartSpan;
  double? _pinchStartFontSize;

  /// Time spent in this book, flushed to a reading session on [dispose].
  late final ReadingSessionRecorder _session;

  /// Captured in `initState`; `ref` cannot be used from `dispose`.
  late final ProgressRepository _progressRepository;
  late final String _deviceId;

  /// Turns `pageTurnId` into the axis a page swipe moves along.
  static Axis _axisFor(String pageTurnId) {
    // Stored values predate the vertical mode: 'slide' meant horizontal.
    return pageTurnId == 'vertical' ? Axis.vertical : Axis.horizontal;
  }

  @override
  void initState() {
    super.initState();
    // Read the repositories now: `ref` is not usable once the element starts
    // tearing down, and both the last progress save and the session flush run
    // from `dispose`.
    _session = ReadingSessionRecorder(
      repository: ref.read(statsRepositoryProvider),
      bookId: widget.bookId,
      minimum: widget.minimumSession,
    )..start(DateTime.now());
    _progressRepository = ref.read(progressRepositoryProvider);
    _deviceId = ref.read(deviceIdProvider);
    unawaited(_restorePosition());
  }

  @override
  void dispose() {
    _prefetchTimer?.cancel();
    _saveProgress();
    unawaited(_session.flush(DateTime.now()));
    _coverSnap?.dispose();
    _coverOffset.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _restorePosition() async {
    final ReadingProgress? progress = await ref
        .read(progressRepositoryProvider)
        .read(widget.bookId);
    if (!mounted) return;
    setState(() {
      _chapterIndex = progress?.chapterIndex ?? 0;
      _restoredOffset = progress?.charOffset ?? -1;
      _restored = true;
    });
  }

  /// Builds a [LayoutSpec] from the saved typography and the current box.
  ///
  /// Everything that changes line boxes has to come from here: the paginator
  /// and the page painter both read the spec, so a saved setting can never
  /// change one without the other.
  LayoutSpec _spec(ReaderSettings settings) => LayoutSpec(
    fontFamily: _fontFamilyFor(settings.fontFamilyId),
    fontSize: settings.fontSize,
    lineHeight: settings.lineHeight,
    paragraphSpacing: settings.paragraphSpacing,
    horizontalPadding: settings.horizontalPadding,
    verticalPadding: _verticalPadding,
    letterSpacing: _letterSpacing,
    textAlign: settings.textAlignId == 'justify' ? LayoutTextAlign.justify : LayoutTextAlign.start,
  );

  /// Maps the stored family id onto a family name the platform resolves.
  ///
  /// 'system' keeps the platform default; the other two are generic families
  /// every Android and desktop install ships, so no font file is bundled
  /// (ADR-0007).
  static String _fontFamilyFor(String fontFamilyId) => switch (fontFamilyId) {
    'serif' => 'serif',
    'monospace' => 'monospace',
    _ => 'System',
  };

  Future<void> _paginate({
    required Chapter chapter,
    required String chapterText,
    required LayoutSpec spec,
    required double width,
    required double height,
  }) async {
    final int token = ++_paginateToken;
    final int cacheHash = pageCacheHash(spec, pageWidth: width, pageHeight: height);
    final String key = '${chapter.index}|$cacheHash';
    if (key == _cacheKey) return;
    _cacheKey = key;
    if (mounted) {
      setState(() {
        _paginating = true;
        _paginateError = null;
      });
    }

    try {
      // Keep the reader where they were: either the position restored from the
      // database, or the character the current page starts at (a font size
      // change re-lays out the whole chapter).
      final int anchor = _restoredOffset >= 0
          ? _restoredOffset
          : (_pages.isEmpty
                ? -1
                : chapter.startOffset + _pages[_pageIndex.clamp(0, _pages.length - 1)].startOffset);
      final List<PageSpan> pages = await _layout(chapter, chapterText, spec, width, height);
      if (!mounted || token != _paginateToken) return;
      final int target = anchor >= 0 ? pageIndexForOffset(pages, anchor - chapter.startOffset) : 0;
      setState(() {
        _pages = pages;
        _layoutHash = cacheHash;
        _contentSize = Size(width, height);
        _paginating = false;
        _pageIndex = target.clamp(0, math.max(0, pages.length - 1));
        _restoredOffset = -1;
      });
      // The PageView is built from `_pages`, so the controller only has clients
      // after the frame that swaps the list; jump once that frame is done.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_pageController.hasClients) return;
        if (_pageController.page?.round() == _pageIndex) return;
        _pageController.jumpToPage(_pageIndex);
      });
      _saveProgress();
      _schedulePrefetch(chapterIndex: chapter.index, spec: spec, width: width, height: height);
    } on Object catch (error, stackTrace) {
      // A failed layout must not leave the reader on a spinner forever.
      if (!mounted || token != _paginateToken) return;
      setState(() {
        _paginating = false;
        _pages = const <PageSpan>[];
        _paginateError = '$error';
      });
      ref.read(loggerProvider).error('pagination failed', error: error, stackTrace: stackTrace);
      _cacheKey = '';
    }
  }

  /// Reads the cached page table for [spec] or measures the chapter and stores
  /// the result.
  Future<List<PageSpan>> _layout(
    Chapter chapter,
    String chapterText,
    LayoutSpec spec,
    double width,
    double height,
  ) async {
    final int cacheHash = pageCacheHash(spec, pageWidth: width, pageHeight: height);
    final PageLayoutRepository cache = ref.read(pageLayoutRepositoryProvider);
    final CachedPageLayout? cached = await cache.read(
      bookId: widget.bookId,
      chapterIndex: chapter.index,
      layoutHash: cacheHash,
    );
    if (cached != null && cached.pages.isNotEmpty) {
      return cached.pages
          .map(
            (PageExtent page) => PageSpan(startOffset: page.startOffset, endOffset: page.endOffset),
          )
          .toList(growable: false);
    }

    final List<PageSpan> pages = await ref
        .read(textLayoutEngineProvider)
        .paginate(
          PaginationRequest(
            chapterIndex: chapter.index,
            text: chapterText,
            spec: spec,
            pageWidth: width,
            pageHeight: height,
          ),
        );
    unawaited(
      cache
          .write(
            CachedPageLayout(
              bookId: widget.bookId,
              chapterIndex: chapter.index,
              layoutHash: cacheHash,
              pages: pages
                  .map(
                    (PageSpan span) =>
                        PageExtent(startOffset: span.startOffset, endOffset: span.endOffset),
                  )
                  .toList(growable: false),
              computedAt: DateTime.now().toUtc(),
            ),
          )
          .catchError((Object _) {}),
    );
    return pages;
  }

  /// Warms the page cache for the chapter after [chapterIndex] once the reader
  /// stops turning pages.
  ///
  /// Measuring needs the font environment, so it cannot move to a background
  /// isolate and Flutter exposes no idle queue; a short debounce keeps the work
  /// out of the frames the reader is interacting with (DEVELOPMENT_PLAN
  /// §3.5.3). Only the cache is written — no state changes, so a prefetch that
  /// lands late can never move the reader.
  void _schedulePrefetch({
    required int chapterIndex,
    required LayoutSpec spec,
    required double width,
    required double height,
  }) {
    if (_fullText.isEmpty) return;
    final int next = chapterIndex + 1;
    if (next >= _chapters.length) return;
    _prefetchTimer?.cancel();
    _prefetchTimer = Timer(
      const Duration(milliseconds: 700),
      () => unawaited(_prefetch(next, spec, width, height)),
    );
  }

  Future<void> _prefetch(int chapterIndex, LayoutSpec spec, double width, double height) async {
    if (!mounted) return;
    try {
      final Chapter chapter = _chapters[chapterIndex];
      final int start = chapter.startOffset.clamp(0, _fullText.length);
      final int end = chapter.endOffset.clamp(start, _fullText.length);
      if (end <= start) return;
      await _layout(chapter, _fullText.substring(start, end), spec, width, height);
    } on Object catch (error) {
      // A prefetch is an optimisation; failing it must not surface anywhere.
      ref.read(loggerProvider).debug('prefetch failed for chapter $chapterIndex: $error');
    }
  }

  Chapter? _chapterAt(int index) {
    if (index < 0 || index >= _chapters.length) return null;
    return _chapters[index];
  }

  /// Jumps to [charOffset] inside [chapterIndex] (bookmark navigation).
  void _jumpTo(int chapterIndex, int charOffset) {
    if (_chapters.isEmpty) return;
    _saveProgress();
    final int target = chapterIndex.clamp(0, _chapters.length - 1);
    setState(() {
      _chapterIndex = target;
      _restoredOffset = _chapters[target].startOffset + charOffset;
      _pages = const <PageSpan>[];
      _pageIndex = 0;
      _cacheKey = '';
      _paginateToken++;
    });
  }

  void _goToChapter(int index) {
    if (_chapters.isEmpty) return;
    final int next = index.clamp(0, _chapters.length - 1);
    if (next == _chapterIndex) return;
    _saveProgress();
    setState(() {
      _chapterIndex = next;
      _pages = const <PageSpan>[];
      _pageIndex = 0;
      _cacheKey = '';
      _paginateToken++;
    });
    _saveProgress();
  }

  void _onPageChanged(int index) {
    setState(() => _pageIndex = index);
    // Characters the reader moved through, for the statistics screen. It is an
    // upper bound: a page that only got skimmed still counts once.
    if (index >= 0 && index < _pages.length) {
      final PageSpan page = _pages[index];
      _session.addCharacters(page.endOffset - page.startOffset);
    }
    _saveProgress();
  }

  /// Fire-and-forget: losing a position is annoying, blocking a page turn is
  /// worse.
  void _saveProgress() {
    if (!_restored || _chapters.isEmpty || _pages.isEmpty) return;
    final Chapter chapter = _chapters[_chapterIndex.clamp(0, _chapters.length - 1)];
    final PageSpan page = _pages[_pageIndex.clamp(0, _pages.length - 1)];
    unawaited(
      _progressRepository
          .save(
            ReadingProgress(
              bookId: widget.bookId,
              chapterIndex: chapter.index,
              charOffset: chapter.startOffset + page.startOffset,
              updatedAt: DateTime.now().toUtc(),
              deviceId: _deviceId,
              pageIndex: _pageIndex,
            ),
          )
          .catchError((Object _) {}),
    );
  }

  void _flip(int delta) {
    if (_pages.isEmpty) return;
    if (delta < 0 && _pageIndex == 0) {
      _goToChapter(_chapterIndex - 1);
      return;
    }
    if (delta > 0 && _pageIndex >= _pages.length - 1) {
      _goToChapter(_chapterIndex + 1);
      return;
    }
    final int target = _pageIndex + delta;
    if (target < 0 || target >= _pages.length) return;
    final String turn = ref.read(readerSettingsControllerProvider).pageTurnId;
    if (turn == 'cover') {
      // Cover mode has no PageView scrolling of its own, so a tap runs the same
      // slide-out the drag would have produced.
      _coverPreview = delta;
      setState(() {});
      _snapCover(delta > 0 ? -_lastWidth : _lastWidth, onDone: () => _commitCoverPage(target));
      return;
    }
    final bool animated = turn == 'slide';
    if (animated) {
      unawaited(
        _pageController.animateToPage(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        ),
      );
    } else {
      _pageController.jumpToPage(target);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.position;
    if (_pointers.length == 2) {
      _pinchStartSpan = _currentSpan();
      _pinchStartFontSize = ref.read(readerSettingsControllerProvider).fontSize;
    } else if (_pointers.length > 2) {
      // Three fingers is a palm or a slip; stop treating it as a pinch.
      _pinchStartSpan = null;
      _pinchStartFontSize = null;
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.position;
    final double? startSpan = _pinchStartSpan;
    final double? startSize = _pinchStartFontSize;
    if (startSpan == null || startSize == null || _pointers.length != 2) return;
    final double size = pinchFontSize(
      startSize: startSize,
      startSpan: startSpan,
      span: _currentSpan(),
    );
    if (size == ref.read(readerSettingsControllerProvider).fontSize) return;
    // Rounding inside pinchFontSize keeps this to at most one re-pagination per
    // whole point size, which is what the slider does too.
    ref.read(readerSettingsControllerProvider.notifier).setFontSize(size);
  }

  void _handlePointerEnd(int pointer) {
    _pointers.remove(pointer);
    if (_pointers.length < 2) {
      _pinchStartSpan = null;
      _pinchStartFontSize = null;
    }
  }

  /// Distance between the first two live pointers, or 0 when there are fewer.
  double _currentSpan() {
    if (_pointers.length < 2) return 0;
    final List<Offset> positions = _pointers.values.take(2).toList(growable: false);
    return (positions[0] - positions[1]).distance;
  }

  /// How far the current page has slid aside in cover mode, in pixels.
  ///
  /// A notifier rather than state: a drag updates it every frame and only the
  /// transform above the page should rebuild, not the text itself.
  final ValueNotifier<double> _coverOffset = ValueNotifier<double>(0);

  /// Page previewed under the one being dragged: +1 for the next, -1 previous.
  int _coverPreview = 0;

  /// Content width of the last layout pass, needed when a tap animates a turn.
  double _lastWidth = 0;

  /// Tweens [_coverOffset] so a released drag settles instead of snapping.
  AnimationController? _coverSnap;
  VoidCallback? _snapListener;

  int _coverNeighbourIndex() {
    if (_coverPreview == 0) return _pageIndex;
    return (_pageIndex + _coverPreview).clamp(0, math.max(0, _pages.length - 1));
  }

  void _startCoverDrag() {
    _coverSnap?.stop();
  }

  void _updateCoverDrag(double delta, double width) {
    final double next = (_coverOffset.value + delta).clamp(-width, width);
    _coverOffset.value = next;
    final int preview = next == 0 ? 0 : (next < 0 ? 1 : -1);
    if (preview != _coverPreview) {
      setState(() => _coverPreview = preview);
    }
  }

  void _endCoverDrag(double velocity, double width) {
    final double offset = _coverOffset.value;
    final int preview = _coverPreview;
    final bool commit = offset.abs() > width * 0.25 || velocity.abs() > 700;
    if (!commit || preview == 0) {
      _snapCover(0);
      return;
    }
    final int target = _pageIndex + preview;
    if (target < 0 || target >= _pages.length) {
      // The page list ends at the chapter boundary, so finish the gesture and
      // let the normal chapter switch take over instead of dragging in a blank.
      _snapCover(0, onDone: () => _flip(preview));
      return;
    }
    _snapCover(preview > 0 ? -width : width, onDone: () => _commitCoverPage(target));
  }

  /// Jumps to [target] and keeps the page counter in step.
  ///
  /// `jumpToPage` alone can leave `onPageChanged` unfired in cover mode, which
  /// would leave the indicator and the saved offset one page behind.
  void _commitCoverPage(int target) {
    _pageController.jumpToPage(target);
    _coverOffset.value = 0;
    setState(() => _coverPreview = 0);
    if (_pageIndex != target) _onPageChanged(target);
  }

  /// Animates the cover offset to [target], then runs [onDone].
  void _snapCover(double target, {VoidCallback? onDone}) {
    final AnimationController controller = _ensureCoverSnap();
    controller.stop();
    final double from = _coverOffset.value;
    final VoidCallback? previous = _snapListener;
    if (previous != null) controller.removeListener(previous);
    void tick() {
      _coverOffset.value = from + (target - from) * Curves.easeOutCubic.transform(controller.value);
    }

    _snapListener = tick;
    controller.addListener(tick);
    unawaited(
      controller.forward(from: 0).whenComplete(() {
        controller.removeListener(tick);
        _snapListener = null;
        if (!mounted) return;
        _coverOffset.value = target;
        if (target == 0 && _coverPreview != 0) {
          setState(() => _coverPreview = 0);
        }
        onDone?.call();
      }),
    );
  }

  AnimationController _ensureCoverSnap() {
    return _coverSnap ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  /// Body of one page: the shared style, selection, and (optionally) taps.
  Widget _pageContent({
    required BuildContext context,
    required int index,
    required String text,
    required int start,
    required int end,
    required LayoutSpec spec,
    required double horizontalPadding,
    required BoxConstraints constraints,
    required bool interactive,
  }) {
    final PageSpan page = _pages[index];
    final int from = (start + page.startOffset).clamp(0, end);
    final int to = (start + page.endOffset).clamp(from, end);
    // `SelectionArea` inside competes for taps in the gesture arena, so taps are
    // read at the pointer level and anything past [_tapSlop] is treated as a
    // swipe.
    // Opaque: in cover mode this page slides across the one underneath, and a
    // transparent sheet would show both texts at once.
    final Widget body = ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        // Keep the first line below the status bar even though the chrome is
        // hidden: the page box is measured with the same insets, so the layout
        // and the drawing agree.
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          math.max(_verticalPadding, MediaQuery.paddingOf(context).top + 8),
          horizontalPadding,
          math.max(_verticalPadding, MediaQuery.paddingOf(context).bottom + 8),
        ),
        child: SizedBox.expand(
          // Long-press selects text and the platform menu offers copy; taps
          // still reach the Listener above.
          child: SelectionArea(
            child: Text(
              text.substring(from, to).trim(),
              // Same style and alignment the paginator measured with, otherwise
              // page breaks drift from the glyphs.
              style: readerTextStyle(spec),
              textAlign: readerTextAlign(spec),
            ),
          ),
        ),
      ),
    );
    if (!interactive) return body;
    return Listener(
      onPointerDown: (PointerDownEvent event) => _tapOrigin = event.localPosition,
      onPointerUp: (PointerUpEvent event) {
        final Offset? origin = _tapOrigin;
        _tapOrigin = null;
        if (origin == null) return;
        if ((event.localPosition - origin).distance > _tapSlop) return;
        final double x = event.localPosition.dx;
        if (x < constraints.maxWidth * 0.3) {
          _flip(-1);
        } else if (x > constraints.maxWidth * 0.7) {
          _flip(1);
        } else {
          // Middle tap toggles the immersive chrome, like the reference reader.
          _toggleChrome();
        }
      },
      onPointerCancel: (PointerCancelEvent event) => _tapOrigin = null,
      child: body,
    );
  }

  String _excerptOf(String pageText) {
    final String collapsed = pageText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.length <= 60) return collapsed;
    return '${collapsed.substring(0, 60)}…';
  }

  Future<void> _addBookmark() async {
    if (_chapters.isEmpty || _pages.isEmpty) return;
    final Chapter chapter = _chapters[_chapterIndex.clamp(0, _chapters.length - 1)];
    final PageSpan page = _pages[_pageIndex.clamp(0, _pages.length - 1)];
    final int from = (chapter.startOffset + page.startOffset).clamp(0, _fullText.length);
    final int to = (chapter.startOffset + page.endOffset).clamp(from, _fullText.length);
    final String excerpt = _excerptOf(_fullText.substring(from, to));
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ModooLocalizations strings = context.l10n;

    final String? note = await _askBookmarkNote(context, excerpt);
    if (note == null || !mounted) return;
    await ref
        .read(bookmarkRepositoryProvider)
        .add(
          Bookmark(
            id: 0,
            bookId: widget.bookId,
            chapterIndex: chapter.index,
            charOffset: page.startOffset,
            excerpt: excerpt,
            note: note.isEmpty ? null : note,
            createdAt: DateTime.now().toUtc(),
          ),
        );
    messenger.showSnackBar(SnackBar(content: Text(strings.bookmarkAdded)));
  }

  Future<String?> _askBookmarkNote(BuildContext context, String excerpt) => showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) => _BookmarkNoteDialog(excerpt: excerpt),
  );

  /// Paragraphs of the current page, with their offsets inside the chapter.
  List<({int start, int end, String text})> _pageParagraphs() {
    if (_pages.isEmpty || _chapters.isEmpty) return const <({int start, int end, String text})>[];
    final Chapter chapter = _chapters[_chapterIndex.clamp(0, _chapters.length - 1)];
    final PageSpan page = _pages[_pageIndex.clamp(0, _pages.length - 1)];
    final int base = chapter.startOffset + page.startOffset;
    final int stop = (chapter.startOffset + page.endOffset).clamp(base, _fullText.length);
    if (base >= stop) return const <({int start, int end, String text})>[];

    final List<({int start, int end, String text})> paragraphs =
        <({int start, int end, String text})>[];
    final String slice = _fullText.substring(base, stop);
    int cursor = 0;
    for (final String line in slice.split('\n')) {
      final String trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        paragraphs.add((start: base + cursor, end: base + cursor + line.length, text: trimmed));
      }
      cursor += line.length + 1;
    }
    return paragraphs;
  }

  Future<void> _writeAnnotation({
    required int start,
    required int end,
    required String excerpt,
    Annotation? existing,
  }) async {
    final String? body = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => _AnnotationDialog(
        title: existing == null ? context.l10n.annotationsTitle : context.l10n.editAnnotation,
        excerpt: excerpt,
        initial: existing?.body ?? '',
      ),
    );
    if (body == null || body.isEmpty || !mounted) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String saved = context.l10n.annotationSaved;
    await ref
        .read(annotationRepositoryProvider)
        .add(
          Annotation(
            id: existing?.id ?? 0,
            bookId: widget.bookId,
            chapterIndex: _chapterIndex,
            startOffset: start,
            endOffset: end,
            excerpt: excerpt,
            body: body,
            createdAt: DateTime.now().toUtc(),
          ),
        );
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(saved)));
  }

  void _openPageAnnotations() {
    final List<({int start, int end, String text})> paragraphs = _pageParagraphs();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final List<Annotation> notes =
                ref.watch(annotationsProvider(widget.bookId)).value ?? const <Annotation>[];
            final Map<int, Annotation> byStart = <int, Annotation>{
              for (final Annotation note in notes)
                if (note.chapterIndex == _chapterIndex) note.startOffset: note,
            };
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text(
                        context.l10n.annotationsThisPage,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: paragraphs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final ({int start, int end, String text}) paragraph = paragraphs[index];
                          final Annotation? note = byStart[paragraph.start];
                          return ListTile(
                            title: Text(
                              paragraph.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            subtitle: note == null
                                ? Text(context.l10n.annotationHint)
                                : Text('${note.body} · ${context.l10n.editAnnotation}'),
                            trailing: Icon(
                              note == null ? Icons.edit_note : Icons.mode_comment,
                              color: note == null ? null : Theme.of(context).colorScheme.primary,
                            ),
                            onTap: () {
                              Navigator.of(sheetContext).pop();
                              unawaited(
                                _writeAnnotation(
                                  start: paragraph.start,
                                  end: paragraph.end,
                                  excerpt: paragraph.text,
                                  existing: note,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openAnnotations() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final AsyncValue<List<Annotation>> notes = ref.watch(
              annotationsProvider(widget.bookId),
            );
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text(
                        context.l10n.annotationsTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: notes.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (Object error, StackTrace _) =>
                            Center(child: Text(context.l10n.errorGeneric)),
                        data: (List<Annotation> items) {
                          if (items.isEmpty) {
                            return Center(child: Text(context.l10n.noAnnotations));
                          }
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Annotation note = items[index];
                              final String chapterTitle =
                                  _chapterAt(note.chapterIndex)?.title ?? '';
                              return ListTile(
                                leading: const Icon(Icons.mode_comment_outlined),
                                title: Text(
                                  note.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '$chapterTitle · ${note.excerpt}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  tooltip: context.l10n.delete,
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => unawaited(
                                    ref.read(annotationRepositoryProvider).delete(note.id),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  _jumpTo(note.chapterIndex, note.startOffset);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openBookmarks() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final AsyncValue<List<Bookmark>> bookmarks = ref.watch(
              bookmarksProvider(widget.bookId),
            );
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text(
                        context.l10n.bookmarksTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: bookmarks.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (Object error, StackTrace _) =>
                            Center(child: Text(context.l10n.errorGeneric)),
                        data: (List<Bookmark> items) {
                          if (items.isEmpty) {
                            return Center(child: Text(context.l10n.noBookmarks));
                          }
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Bookmark bookmark = items[index];
                              final String chapterTitle =
                                  _chapterAt(bookmark.chapterIndex)?.title ?? '';
                              final String? note = bookmark.note;
                              return ListTile(
                                leading: const Icon(Icons.bookmark_outline),
                                title: Text(
                                  bookmark.excerpt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  note == null || note.isEmpty
                                      ? chapterTitle
                                      : '$chapterTitle · $note',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  tooltip: context.l10n.delete,
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => unawaited(
                                    ref.read(bookmarkRepositoryProvider).delete(bookmark.id),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  _jumpTo(bookmark.chapterIndex, bookmark.charOffset);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openSearch() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return _SearchSheet(
          bookText: _fullText,
          chapters: _chapters,
          onSelected: (int chapterIndex, int charOffset) {
            Navigator.of(sheetContext).pop();
            _jumpTo(chapterIndex, charOffset);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Chapter>> chapters = ref.watch(chaptersProvider(widget.bookId));
    final AsyncValue<String> text = ref.watch(bookTextProvider(widget.bookId));
    final ReaderSettings settings = ref.watch(readerSettingsControllerProvider);
    final String bookTitle = ref.watch(bookByIdProvider(widget.bookId)).value?.title ?? '';

    if (chapters.hasValue) {
      _chapters = chapters.requireValue;
      if (_restored && _chapters.isNotEmpty && _chapterIndex >= _chapters.length) {
        _chapterIndex = _chapters.length - 1;
      }
    }

    final Widget body;
    if (chapters.hasError) {
      body = _buildError('${chapters.error}');
    } else if (text.hasError) {
      body = _buildError('${text.error}');
    } else if (chapters.hasValue && text.hasValue) {
      body = _buildPagedBody(context, chapters.requireValue, text.requireValue, settings);
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      key: _scaffoldKey,
      // The table of contents slides in from the left, the way the reference
      // reader opens it; the bottom sheet was too shallow for long books.
      drawer: _chapters.isEmpty
          ? null
          : _TocDrawer(
              chapters: _chapters,
              currentIndex: _chapterIndex,
              bookTitle: bookTitle,
              onSelected: (int index) {
                Navigator.of(context).pop();
                _goToChapter(index);
              },
            ),
      body: Stack(
        // Everything lives in positioned children: with a loose Stack the body
        // would be laid out against the top bar's height instead of the screen.
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(child: body),
          // Immersive chrome: hidden until the reader taps the middle.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 180),
              offset: _chromeVisible ? Offset.zero : const Offset(0, -1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _chromeVisible ? 1 : 0,
                child: IgnorePointer(ignoring: !_chromeVisible, child: _buildTopBar(context)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 180),
              offset: _chromeVisible ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _chromeVisible ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_chromeVisible,
                  child: _chapters.isEmpty
                      ? const SizedBox.shrink()
                      : _buildReaderBottomBar(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double progress = _readingProgress();
    return SafeArea(
      bottom: false,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
        child: Row(
          children: <Widget>[
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _currentChapterTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    '${_chapterIndex + 1}/${_chapters.length} · ${(progress * 100).round()}%',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.searchTitle,
              onPressed: _fullText.isEmpty ? null : _openSearch,
              icon: const Icon(Icons.search),
            ),
            PopupMenuButton<void>(
              tooltip: context.l10n.readerSettings,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<void>>[
                PopupMenuItem<void>(
                  enabled: _pages.isNotEmpty,
                  onTap: () => unawaited(_addBookmark()),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bookmark_add_outlined),
                    title: Text(context.l10n.addBookmark),
                  ),
                ),
                PopupMenuItem<void>(
                  onTap: _openBookmarks,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bookmarks_outlined),
                    title: Text(context.l10n.bookmarksTitle),
                  ),
                ),
                PopupMenuItem<void>(
                  enabled: _pages.isNotEmpty,
                  onTap: _openPageAnnotations,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.mode_comment_outlined),
                    title: Text(context.l10n.annotationsThisPage),
                  ),
                ),
                PopupMenuItem<void>(
                  onTap: _openAnnotations,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notes_outlined),
                    title: Text(context.l10n.annotationsTitle),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Progress through the whole book, in `0..1`.
  double _readingProgress() {
    if (_chapters.isEmpty) return 0;
    final double withinChapter = _pages.isEmpty ? 0 : _pageIndex / _pages.length;
    final double value = (_chapterIndex + withinChapter) / _chapters.length;
    return value.clamp(0, 1);
  }

  void _toggleChrome() => setState(() => _chromeVisible = !_chromeVisible);

  String _currentChapterTitle(BuildContext context) {
    if (_chapters.isEmpty) return context.l10n.appName;
    return _chapters[_chapterIndex.clamp(0, _chapters.length - 1)].title;
  }

  Widget _buildError(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );

  Widget _buildPagedBody(
    BuildContext context,
    List<Chapter> chapters,
    String text,
    ReaderSettings settings,
  ) {
    if (chapters.isEmpty) {
      return Center(child: Text(context.l10n.errorGeneric));
    }
    final Chapter chapter = chapters[_chapterIndex.clamp(0, chapters.length - 1)];
    _fullText = text;
    final int start = chapter.startOffset.clamp(0, text.length);
    final int end = chapter.endOffset.clamp(start, text.length);
    final String chapterText = text.substring(start, end);
    final LayoutSpec spec = _spec(settings);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double horizontalPadding = settings.horizontalPadding;
        _lastWidth = constraints.maxWidth;
        final double width = math.max(80, constraints.maxWidth - horizontalPadding * 2);
        final EdgeInsets insets = MediaQuery.paddingOf(context);
        final double topInset = math.max(_verticalPadding, insets.top + 8);
        final double bottomInset = math.max(_verticalPadding, insets.bottom + 8);
        final double height = math.max(80, constraints.maxHeight - topInset - bottomInset);
        final bool stale =
            _pages.isEmpty ||
            _layoutHash != pageCacheHash(spec, pageWidth: width, pageHeight: height) ||
            _contentSize != Size(width, height);
        // Measuring has side effects (cache writes, setState), so it must not
        // run inside the layout/build phase: schedule it for after the frame.
        if (stale && !_paginating && !_paginateScheduled && _restored) {
          _paginateScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((Duration _) {
            _paginateScheduled = false;
            if (!mounted) return;
            unawaited(
              _paginate(
                chapter: chapter,
                chapterText: chapterText,
                spec: spec,
                width: width,
                height: height,
              ),
            );
          });
        }
        if (_pages.isEmpty) {
          if (_paginateError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(context.l10n.errorGeneric, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => setState(() {
                        _cacheKey = '';
                        _paginateError = null;
                      }),
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        }
        final Axis axis = _axisFor(settings.pageTurnId);
        final bool cover = settings.pageTurnId == 'cover';
        final Widget pager = PageView.builder(
          key: ValueKey<String>(settings.pageTurnId),
          scrollDirection: axis,
          physics: cover ? const NeverScrollableScrollPhysics() : null,
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (BuildContext context, int index) => _pageContent(
            context: context,
            index: index,
            text: text,
            start: start,
            end: end,
            spec: spec,
            horizontalPadding: horizontalPadding,
            constraints: constraints,
            interactive: true,
          ),
        );

        final Widget paged = Listener(
          // Pinch is observed above the PageView: when two fingers land on
          // different pages the per-page listeners would only see one each.
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: (PointerUpEvent event) => _handlePointerEnd(event.pointer),
          onPointerCancel: (PointerCancelEvent event) => _handlePointerEnd(event.pointer),
          child: cover
              ? ValueListenableBuilder<double>(
                  valueListenable: _coverOffset,
                  builder: (BuildContext context, double offset, Widget? child) =>
                      Transform.translate(offset: Offset(offset, 0), child: child),
                  child: pager,
                )
              : pager,
        );

        return Stack(
          children: <Widget>[
            if (cover)
              // The page being uncovered: it sits still while the current one
              // slides away, which is what makes the effect read as a card
              // being pulled off the stack instead of two pages swapping.
              IgnorePointer(
                child: ValueListenableBuilder<double>(
                  valueListenable: _coverOffset,
                  builder: (BuildContext context, double offset, Widget? child) {
                    if (offset == 0) return const SizedBox.shrink();
                    return child!;
                  },
                  child: _pageContent(
                    context: context,
                    index: _coverNeighbourIndex(),
                    text: text,
                    start: start,
                    end: end,
                    spec: spec,
                    horizontalPadding: horizontalPadding,
                    constraints: constraints,
                    interactive: false,
                  ),
                ),
              ),
            if (cover)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (DragStartDetails details) => _startCoverDrag(),
                onHorizontalDragUpdate: (DragUpdateDetails details) =>
                    _updateCoverDrag(details.primaryDelta ?? 0, constraints.maxWidth),
                onHorizontalDragEnd: (DragEndDetails details) =>
                    _endCoverDrag(details.primaryVelocity ?? 0, constraints.maxWidth),
                child: paged,
              )
            else
              paged,
            // Hidden while the chrome is up: the bottom bar covers this corner.
            IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: _chromeVisible ? 0 : 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 4),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${_pageIndex + 1} / ${_pages.length}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Bottom chrome: a scrubbable progress bar plus the four reader actions.
  Widget _buildReaderBottomBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double progress = _readingProgress();
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: <Widget>[
                  Text(
                    '${_chapterIndex + 1}/${_chapters.length}',
                    style: theme.textTheme.labelSmall,
                  ),
                  Expanded(
                    child: Slider(
                      value: progress,
                      onChanged: (double value) {
                        final int target = (value * _chapters.length).floor().clamp(
                          0,
                          _chapters.length - 1,
                        );
                        if (target != _chapterIndex) _goToChapter(target);
                      },
                    ),
                  ),
                  Text('${(progress * 100).round()}%', style: theme.textTheme.labelSmall),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _ChromeAction(
                    icon: Icons.menu_book_outlined,
                    label: context.l10n.tocTitle,
                    onTap: _openToc,
                  ),
                  _ChromeAction(
                    icon: Icons.headphones_outlined,
                    label: context.l10n.listen,
                    onTap: () => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(context.l10n.listenComingSoon))),
                  ),
                  _ChromeAction(
                    icon: Icons.nightlight_outlined,
                    label: context.l10n.settingsTheme,
                    onTap: _cycleTheme,
                  ),
                  _ChromeAction(
                    icon: Icons.text_fields,
                    label: context.l10n.readerSettings,
                    onTap: _openSettings,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cycles paper → sepia → night → black, like the quick toggle in the
  /// reference reader.
  void _cycleTheme() {
    const List<AppThemeVariant> order = <AppThemeVariant>[
      AppThemeVariant.paper,
      AppThemeVariant.sepia,
      AppThemeVariant.night,
      AppThemeVariant.amoled,
    ];
    final AppThemeVariant current = ref.read(appThemeProvider);
    final int index = order.indexOf(current);
    final AppThemeVariant next = order[(index + 1) % order.length];
    ref.read(readerSettingsControllerProvider.notifier).setThemeId(next.name);
  }

  void _openToc() => _scaffoldKey.currentState?.openDrawer();

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final ReaderSettings settings = ref.watch(readerSettingsControllerProvider);
            final ReaderSettingsController controller = ref.read(
              readerSettingsControllerProvider.notifier,
            );
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.readerSettings,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text('${context.l10n.readerFontSize}  ${settings.fontSize.round()}'),
                    Slider(
                      value: settings.fontSize,
                      min: 14,
                      max: 30,
                      divisions: 16,
                      onChanged: controller.setFontSize,
                    ),
                    Text(
                      '${context.l10n.readerLineHeight}  ${settings.lineHeight.toStringAsFixed(1)}',
                    ),
                    Slider(
                      value: settings.lineHeight,
                      min: 1.2,
                      max: 2.4,
                      divisions: 12,
                      onChanged: controller.setLineHeight,
                    ),
                    Text(
                      '${context.l10n.readerParagraphSpacing}  '
                      '${settings.paragraphSpacing.toStringAsFixed(1)}',
                    ),
                    Slider(
                      value: settings.paragraphSpacing,
                      min: 0,
                      max: 1.5,
                      divisions: 15,
                      onChanged: controller.setParagraphSpacing,
                    ),
                    Text('${context.l10n.readerMargin}  ${settings.horizontalPadding.round()}'),
                    Slider(
                      value: settings.horizontalPadding,
                      min: 8,
                      max: 40,
                      divisions: 16,
                      onChanged: controller.setHorizontalPadding,
                    ),
                    const SizedBox(height: 4),
                    Text(context.l10n.readerFont, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'system',
                          label: Text(context.l10n.readerFontSystem),
                        ),
                        ButtonSegment<String>(
                          value: 'serif',
                          label: Text(context.l10n.readerFontSerif),
                        ),
                        ButtonSegment<String>(
                          value: 'monospace',
                          label: Text(context.l10n.readerFontMono),
                        ),
                      ],
                      selected: <String>{settings.fontFamilyId},
                      onSelectionChanged: (Set<String> selection) =>
                          controller.setFontFamilyId(selection.first),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.readerTextAlign,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'start',
                          label: Text(context.l10n.readerAlignStart),
                        ),
                        ButtonSegment<String>(
                          value: 'justify',
                          label: Text(context.l10n.readerAlignJustify),
                        ),
                      ],
                      selected: <String>{settings.textAlignId},
                      onSelectionChanged: (Set<String> selection) =>
                          controller.setTextAlignId(selection.first),
                    ),
                    const SizedBox(height: 12),
                    Text(context.l10n.settingsTheme, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    // Background swatches, the way the reference reader offers
                    // its paper colours.
                    Row(
                      children: <Widget>[
                        for (final AppThemeVariant variant in AppThemeVariant.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _ThemeSwatch(
                              variant: variant,
                              selected: settings.themeId == variant.name,
                              onTap: () => controller.setThemeId(variant.name),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.readerPageTurn,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'vertical',
                          label: Text(context.l10n.pageTurnVertical),
                        ),
                        ButtonSegment<String>(
                          value: 'slide',
                          label: Text(context.l10n.pageTurnHorizontal),
                        ),
                        ButtonSegment<String>(
                          value: 'cover',
                          label: Text(context.l10n.pageTurnCover),
                        ),
                        ButtonSegment<String>(
                          value: 'none',
                          label: Text(context.l10n.pageTurnNone),
                        ),
                      ],
                      selected: <String>{settings.pageTurnId},
                      onSelectionChanged: (Set<String> selection) =>
                          controller.setPageTurnId(selection.first),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// A round background swatch in the typography sheet.
class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.variant, required this.selected, required this.onTap});

  final AppThemeVariant variant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalette.of(variant);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: palette.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : palette.divider,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: Text('A', style: TextStyle(color: palette.foreground, fontSize: 16)),
      ),
    );
  }
}

/// One labelled action in the reader's bottom chrome.
class _ChromeAction extends StatelessWidget {
  const _ChromeAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 22),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

/// Asks for an optional note before storing a bookmark.
///
/// The controller lives in this widget so it is disposed after the dialog
/// route has finished animating out; disposing it as soon as `showDialog`
/// returns trips Flutter's `_dependents.isEmpty` assertion.
class _BookmarkNoteDialog extends StatefulWidget {
  const _BookmarkNoteDialog({required this.excerpt});

  final String excerpt;

  @override
  State<_BookmarkNoteDialog> createState() => _BookmarkNoteDialogState();
}

class _BookmarkNoteDialogState extends State<_BookmarkNoteDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ModooLocalizations strings = context.l10n;
    return AlertDialog(
      title: Text(strings.addBookmark),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.excerpt,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: strings.bookmarkNoteHint),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.cancel)),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(strings.save),
        ),
      ],
    );
  }
}

/// Editor for a paragraph note.
///
/// Same controller-ownership rule as [_BookmarkNoteDialog]: the controller lives
/// in the state so it outlives the dialog's exit animation.
class _AnnotationDialog extends StatefulWidget {
  const _AnnotationDialog({required this.title, required this.excerpt, required this.initial});

  final String title;
  final String excerpt;
  final String initial;

  @override
  State<_AnnotationDialog> createState() => _AnnotationDialogState();
}

class _AnnotationDialogState extends State<_AnnotationDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial)
    ..selection = TextSelection.collapsed(offset: widget.initial.length);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ModooLocalizations strings = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.excerpt,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 2,
            maxLines: 6,
            decoration: InputDecoration(hintText: strings.annotationHint),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(strings.cancel)),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(strings.save),
        ),
      ],
    );
  }
}

/// Full-text search over one book.
///
/// The scan itself is [searchBook] in `modoo_reader_engine` (pure Dart, literal
/// match); this widget only owns the query text and the result list.
/// Table of contents, sliding in from the left.
class _TocDrawer extends StatelessWidget {
  const _TocDrawer({
    required this.chapters,
    required this.currentIndex,
    required this.bookTitle,
    required this.onSelected,
  });

  final List<Chapter> chapters;
  final int currentIndex;
  final String bookTitle;
  final void Function(int index) onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (bookTitle.isNotEmpty)
                    Text(
                      bookTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.chaptersCount(chapters.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: chapters.length,
                itemBuilder: (BuildContext context, int index) {
                  final bool selected = index == currentIndex;
                  return ListTile(
                    dense: true,
                    selected: selected,
                    selectedColor: theme.colorScheme.primary,
                    title: Text(
                      chapters[index].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSelected(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({required this.bookText, required this.chapters, required this.onSelected});

  final String bookText;
  final List<Chapter> chapters;
  final void Function(int chapterIndex, int charOffset) onSelected;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final TextEditingController _query = TextEditingController();
  List<SearchHit> _hits = const <SearchHit>[];
  bool _searched = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _run(String value) {
    final String query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _hits = const <SearchHit>[];
        _searched = false;
      });
      return;
    }
    final List<ChapterSpan> spans = widget.chapters
        .map(
          (Chapter chapter) => ChapterSpan(
            index: chapter.index,
            title: chapter.title,
            startOffset: chapter.startOffset,
            endOffset: chapter.endOffset,
          ),
        )
        .toList(growable: false);
    setState(() {
      _hits = searchBook(text: widget.bookText, chapters: spans, query: query);
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ModooLocalizations strings = context.l10n;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: _query,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: strings.searchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: _run,
                onSubmitted: _run,
              ),
            ),
            if (_searched)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  _hits.isEmpty ? strings.searchNoResults : strings.searchResults(_hits.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _hits.length,
                itemBuilder: (BuildContext context, int index) {
                  final SearchHit hit = _hits[index];
                  return ListTile(
                    dense: true,
                    title: Text(hit.snippet, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${hit.chapterTitle} · ${hit.charOffset + 1}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => widget.onSelected(hit.chapterIndex, hit.charOffset),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
