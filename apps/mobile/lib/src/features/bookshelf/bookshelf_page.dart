import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modoo_core/modoo_core.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_l10n/modoo_l10n.dart';
import 'package:modoo_ui/modoo_ui.dart';

import '../../providers/app_providers.dart';
import '../import/import_controller.dart';
import '../import/import_service.dart';
import '../reader/reader_page.dart';

/// The shelf: streams books from the database and shows the four states
/// every list in this app must handle (loading, error, empty, data).
class BookshelfPage extends ConsumerWidget {
  const BookshelfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Book>> books = ref.watch(booksProvider);
    final ImportState importState = ref.watch(importControllerProvider);

    ref.listen<ImportState>(importControllerProvider, (ImportState? previous, ImportState next) {
      final ImportController controller = ref.read(importControllerProvider.notifier);
      switch (next.phase) {
        case ImportPhase.done:
          final ImportOutcome? outcome = next.outcome;
          if (outcome != null) {
            _snack(context, context.l10n.importSucceeded(outcome.book.title, outcome.chapterCount));
          }
          controller.reset();
        case ImportPhase.failed:
          _snack(context, _messageForFailure(context, next.errorCode));
          controller.reset();
        case ImportPhase.idle:
        case ImportPhase.picking:
        case ImportPhase.running:
          break;
      }
    });

    final Widget content = books.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object error, StackTrace stack) => ModooEmptyState(
        title: context.l10n.errorGeneric,
        message: '$error',
        icon: Icons.error_outline,
        action: FilledButton(
          onPressed: () => ref.invalidate(booksProvider),
          child: Text(context.l10n.retry),
        ),
      ),
      data: (List<Book> items) {
        if (items.isEmpty) {
          return ModooEmptyState(
            title: context.l10n.bookshelfEmptyTitle,
            message: context.l10n.bookshelfEmptyMessage,
            action: FilledButton.icon(
              onPressed: importState.isBusy ? null : () => _import(context, ref),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.importBook),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl * 2,
          ),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            mainAxisSpacing: AppSpacing.xl,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.58,
          ),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final Book book = items[index];
            return _BookTile(
              book: book,
              onOpen: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => ReaderPage(bookId: book.id),
                ),
              ),
              onDelete: () => _delete(context, ref, book),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bookshelfTitle)),
      floatingActionButton: books.value == null || books.requireValue.isEmpty
          ? null
          : FloatingActionButton(
              tooltip: context.l10n.importBook,
              onPressed: importState.isBusy ? null : () => _import(context, ref),
              child: const Icon(Icons.add),
            ),
      body: Stack(
        children: <Widget>[
          content,
          if (importState.isBusy) _ImportOverlay(state: importState),
        ],
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final ImportOutcome? outcome = await ref
        .read(importControllerProvider.notifier)
        .pickAndImport();
    if (outcome != null && context.mounted) {
      // The shelf refreshes itself through the drift stream; jumping straight
      // into the book is what a reader wants right after importing.
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ReaderPage(bookId: outcome.book.id),
        ),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Book book) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteBookTitle),
        content: Text(context.l10n.deleteBookMessage(book.title)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(bookRepositoryProvider).softDelete(book.id);
    }
  }

  static String _messageForFailure(BuildContext context, String? code) {
    final ModooLocalizations l10n = context.l10n;
    return switch (code) {
      UnsupportedFormatException.codeValue => l10n.importUnsupportedFormat,
      ParseException.codeValue => l10n.importParseFailed,
      StorageException.codeValue => l10n.importStorageFailed,
      _ => l10n.importFailedGeneric,
    };
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// A shelf tile: a generated cover, the title, and how far the reader got.
///
/// There is no cover image in the database yet (the importer does not extract
/// one), so the cover is drawn from the title: a stable gradient per book plus
/// the first character. Swapping in a real cover later only touches this widget.
final class _BookTile extends ConsumerWidget {
  const _BookTile({required this.book, required this.onOpen, required this.onDelete});

  final Book book;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ReadingProgress?> progress = ref.watch(readingProgressProvider(book.id));
    final double fraction = switch (progress.value) {
      null => 0,
      final ReadingProgress value when book.chapterCount > 0 =>
        ((value.chapterIndex + 1) / book.chapterCount).clamp(0.0, 1.0),
      _ => 0,
    };
    final bool started = progress.value != null;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onOpen,
      onLongPress: () => _showActions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _BookCover(title: book.title),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 3,
                      backgroundColor: Colors.black12,
                    ),
                  ),
                  if (started)
                    Positioned(
                      right: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: Text(
                        '${progress.value!.chapterIndex + 1}/${book.chapterCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          shadows: const <Shadow>[Shadow(blurRadius: 4, color: Colors.black54)],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            '${book.formatId.toUpperCase()} · ${context.l10n.chaptersCount(book.chapterCount)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(context.l10n.delete),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Deterministic placeholder cover: same title always gets the same colours.
final class _BookCover extends StatelessWidget {
  const _BookCover({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // `String.hashCode` is not stable across runs on all platforms, so the hue
    // is derived from the code units instead: the same title always gets the
    // same cover, and neighbouring titles do not collide.
    final int seed = title.codeUnits.fold<int>(
      7,
      (int acc, int unit) => (acc * 31 + unit) & 0x3fffffff,
    );
    final HSLColor base = HSLColor.fromAHSL(1, (seed % 360).toDouble(), 0.32, 0.72);
    final Color top = base.withLightness(0.78).toColor();
    final Color bottom = base.withLightness(0.52).toColor();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[top, bottom],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            title.characters.isEmpty ? '?' : title.characters.first,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

final class _ImportOverlay extends StatelessWidget {
  const _ImportOverlay({required this.state});

  final ImportState state;

  @override
  Widget build(BuildContext context) {
    final int percent = (state.progress * 100).round();
    return Positioned.fill(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(context.l10n.importInProgress),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: 220,
                    child: LinearProgressIndicator(
                      value: state.phase == ImportPhase.picking ? null : state.progress,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('$percent%'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
