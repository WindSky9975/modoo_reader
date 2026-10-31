import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_l10n/modoo_l10n.dart';
import 'package:modoo_reader_engine/modoo_reader_engine.dart';

import '../../providers/app_providers.dart';

/// Paginated reader.
///
/// Pages are character ranges measured with `TextPainter` (packages/ui) and
/// cached per `layoutHash` (DEVELOPMENT_PLAN §3.5.3). Positions are saved as
/// `(chapterIndex, charOffset)` so changing the font size never loses the
/// reader's place.
class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  static const double _horizontalPadding = 24;
  static const double _verticalPadding = 20;

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

  @override
  void initState() {
    super.initState();
    unawaited(_restorePosition());
  }

  @override
  void dispose() {
    _prefetchTimer?.cancel();
    _saveProgress();
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
  LayoutSpec _spec(ReaderSettings settings) => LayoutSpec(
    fontFamily: 'System',
    fontSize: settings.fontSize,
    lineHeight: settings.lineHeight,
    paragraphSpacing: 0.6,
    horizontalPadding: _horizontalPadding,
    verticalPadding: _verticalPadding,
    letterSpacing: 0.2,
  );

  Future<void> _paginate({
    required Chapter chapter,
    required String chapterText,
    required LayoutSpec spec,
    required double width,
    required double height,
  }) async {
    final int token = ++_paginateToken;
    final String key = '${chapter.index}|${spec.layoutHash}|${width.round()}|${height.round()}';
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
        _layoutHash = spec.layoutHash;
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
    final PageLayoutRepository cache = ref.read(pageLayoutRepositoryProvider);
    final CachedPageLayout? cached = await cache.read(
      bookId: widget.bookId,
      chapterIndex: chapter.index,
      layoutHash: spec.layoutHash,
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
              layoutHash: spec.layoutHash,
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
    _saveProgress();
  }

  /// Fire-and-forget: losing a position is annoying, blocking a page turn is
  /// worse.
  void _saveProgress() {
    if (!_restored || _chapters.isEmpty || _pages.isEmpty) return;
    final Chapter chapter = _chapters[_chapterIndex.clamp(0, _chapters.length - 1)];
    final PageSpan page = _pages[_pageIndex.clamp(0, _pages.length - 1)];
    unawaited(
      ref
          .read(progressRepositoryProvider)
          .save(
            ReadingProgress(
              bookId: widget.bookId,
              chapterIndex: chapter.index,
              charOffset: chapter.startOffset + page.startOffset,
              updatedAt: DateTime.now().toUtc(),
              deviceId: ref.read(deviceIdProvider),
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
    final bool animated = ref.read(readerSettingsControllerProvider).pageTurnId == 'slide';
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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Chapter>> chapters = ref.watch(chaptersProvider(widget.bookId));
    final AsyncValue<String> text = ref.watch(bookTextProvider(widget.bookId));
    final ReaderSettings settings = ref.watch(readerSettingsControllerProvider);

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
      appBar: AppBar(
        title: Text(_currentChapterTitle(context), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            tooltip: context.l10n.addBookmark,
            onPressed: _pages.isEmpty ? null : () => unawaited(_addBookmark()),
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
          IconButton(
            tooltip: context.l10n.bookmarksTitle,
            onPressed: _openBookmarks,
            icon: const Icon(Icons.bookmarks_outlined),
          ),
          IconButton(
            tooltip: context.l10n.tocTitle,
            onPressed: _chapters.isEmpty ? null : _openToc,
            icon: const Icon(Icons.list),
          ),
          IconButton(
            tooltip: context.l10n.readerSettings,
            onPressed: _openSettings,
            icon: const Icon(Icons.format_size),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: _chapters.isEmpty ? null : _buildBottomBar(context),
    );
  }

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
        final double width = math.max(80, constraints.maxWidth - _horizontalPadding * 2);
        final double height = math.max(80, constraints.maxHeight - _verticalPadding * 2);
        final bool stale =
            _pages.isEmpty || _layoutHash != spec.layoutHash || _contentSize != Size(width, height);
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
        return Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (BuildContext context, int index) {
                final PageSpan page = _pages[index];
                final int from = (start + page.startOffset).clamp(0, end);
                final int to = (start + page.endOffset).clamp(from, end);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (TapUpDetails details) {
                    final double x = details.localPosition.dx;
                    if (x < constraints.maxWidth * 0.3) {
                      _flip(-1);
                    } else if (x > constraints.maxWidth * 0.7) {
                      _flip(1);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _horizontalPadding,
                      vertical: _verticalPadding,
                    ),
                    child: SizedBox.expand(
                      child: Text(
                        text.substring(from, to).trim(),
                        style: TextStyle(
                          fontSize: settings.fontSize,
                          height: settings.lineHeight,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: 12,
              bottom: 4,
              child: Text(
                '${_pageIndex + 1} / ${_pages.length}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: <Widget>[
            TextButton(
              onPressed: _chapterIndex > 0 ? () => _goToChapter(_chapterIndex - 1) : null,
              child: Text(context.l10n.previousChapter),
            ),
            Expanded(
              child: Text(
                '${_chapterIndex + 1} / ${_chapters.length}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: _chapterIndex < _chapters.length - 1
                  ? () => _goToChapter(_chapterIndex + 1)
                  : null,
              child: Text(context.l10n.nextChapter),
            ),
          ],
        ),
      ),
    );
  }

  void _openToc() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            builder: (BuildContext context, ScrollController controller) {
              return ListView.builder(
                controller: controller,
                itemCount: _chapters.length,
                itemBuilder: (BuildContext context, int index) {
                  final Chapter chapter = _chapters[index];
                  return ListTile(
                    selected: index == _chapterIndex,
                    title: Text(chapter.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _goToChapter(index);
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

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
              child: Padding(
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
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.readerPageTurn,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: <ButtonSegment<String>>[
                        ButtonSegment<String>(
                          value: 'slide',
                          label: Text(context.l10n.pageTurnSlide),
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
