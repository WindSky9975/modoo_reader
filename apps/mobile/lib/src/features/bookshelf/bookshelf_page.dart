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
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            final Book book = items[index];
            return ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                book.author ?? book.formatId.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    context.l10n.chaptersCount(book.chapterCount),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'delete') {
                        _delete(context, ref, book);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(value: 'delete', child: Text(context.l10n.delete)),
                    ],
                  ),
                ],
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => ReaderPage(bookId: book.id),
                ),
              ),
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
