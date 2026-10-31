import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_l10n/modoo_l10n.dart';

import '../../providers/app_providers.dart';

/// Vertical scrolling reader, v1 of the reading surface.
///
/// Scope is deliberately small (see ADR-0004): one chapter at a time, scroll
/// only, chapter-level progress. Pagination and page-turn animation land in M2.
class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  final ScrollController _scroll = ScrollController();
  int _index = 0;
  bool _restored = false;
  double _fontSize = 18;
  double _lineHeight = 1.6;
  List<Chapter> _chapters = const <Chapter>[];

  @override
  void initState() {
    super.initState();
    unawaited(_restorePosition());
  }

  @override
  void dispose() {
    _saveProgress();
    _scroll.dispose();
    super.dispose();
  }

  /// Resumes where the reader left off; a deleted book falls back to chapter 1.
  Future<void> _restorePosition() async {
    final ReadingProgress? progress = await ref
        .read(progressRepositoryProvider)
        .read(widget.bookId);
    if (!mounted) {
      return;
    }
    setState(() {
      _index = progress?.chapterIndex ?? 0;
      _restored = true;
    });
  }

  void _goTo(int index) {
    if (_chapters.isEmpty) {
      return;
    }
    final int next = index.clamp(0, _chapters.length - 1);
    if (next == _index) {
      return;
    }
    setState(() => _index = next);
    if (_scroll.hasClients) {
      _scroll.jumpTo(0);
    }
    _saveProgress();
  }

  /// Fire-and-forget: losing a position is annoying, blocking the UI is worse.
  void _saveProgress() {
    if (!_restored || _chapters.isEmpty) {
      return;
    }
    final Chapter chapter = _chapters[_index.clamp(0, _chapters.length - 1)];
    unawaited(
      ref
          .read(progressRepositoryProvider)
          .save(
            ReadingProgress(
              bookId: widget.bookId,
              chapterIndex: chapter.index,
              charOffset: chapter.startOffset,
              updatedAt: DateTime.now().toUtc(),
              deviceId: ref.read(deviceIdProvider),
              pageIndex: 0,
            ),
          )
          .catchError((Object _) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Chapter>> chapters = ref.watch(chaptersProvider(widget.bookId));
    final AsyncValue<String> text = ref.watch(bookTextProvider(widget.bookId));

    if (chapters.hasValue) {
      _chapters = chapters.requireValue;
      if (_restored && _chapters.isNotEmpty && _index >= _chapters.length) {
        _index = _chapters.length - 1;
      }
    }

    final Widget body;
    if (chapters.hasError) {
      body = _buildError('${chapters.error}');
    } else if (text.hasError) {
      body = _buildError('${text.error}');
    } else if (chapters.hasValue && text.hasValue) {
      body = _buildBody(context, chapters.requireValue, text.requireValue);
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        actions: <Widget>[
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

  Widget _buildError(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );

  Widget _buildBody(BuildContext context, List<Chapter> chapters, String text) {
    if (chapters.isEmpty) {
      return Center(child: Text(context.l10n.errorGeneric));
    }
    final Chapter chapter = chapters[_index.clamp(0, chapters.length - 1)];
    final int start = chapter.startOffset.clamp(0, text.length);
    final int end = chapter.endOffset.clamp(start, text.length);
    final String body = text.substring(start, end);
    final bool isLast = _index >= chapters.length - 1;

    return Scrollbar(
      controller: _scroll,
      child: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              chapter.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Text(
              body.trim(),
              style: TextStyle(fontSize: _fontSize, height: _lineHeight, letterSpacing: 0.2),
            ),
            const SizedBox(height: 32),
            Center(
              child: isLast
                  ? Text(context.l10n.endOfChapter, style: Theme.of(context).textTheme.bodySmall)
                  : OutlinedButton(
                      onPressed: () => _goTo(_index + 1),
                      child: Text(context.l10n.nextChapter),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: <Widget>[
            TextButton(
              onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
              child: Text(context.l10n.previousChapter),
            ),
            Expanded(
              child: Text(
                '${_index + 1} / ${_chapters.length}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: _index < _chapters.length - 1 ? () => _goTo(_index + 1) : null,
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
                    selected: index == _index,
                    title: Text(chapter.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _goTo(index);
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
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
                    Text('${context.l10n.readerFontSize}  ${_fontSize.round()}'),
                    Slider(
                      value: _fontSize,
                      min: 14,
                      max: 30,
                      divisions: 16,
                      onChanged: (double value) {
                        setSheetState(() => _fontSize = value);
                        setState(() {});
                      },
                    ),
                    Text('${context.l10n.readerLineHeight}  ${_lineHeight.toStringAsFixed(1)}'),
                    Slider(
                      value: _lineHeight,
                      min: 1.2,
                      max: 2.4,
                      divisions: 12,
                      onChanged: (double value) {
                        setSheetState(() => _lineHeight = value);
                        setState(() {});
                      },
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
