import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modoo_domain/modoo_domain.dart';
import 'package:modoo_l10n/modoo_l10n.dart';
import 'package:modoo_ui/modoo_ui.dart';

import '../../providers/app_providers.dart';

/// The shelf: streams books from the database and shows the four states
/// every list in this app must handle (loading, error, empty, data).
class BookshelfPage extends ConsumerWidget {
  const BookshelfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.bookshelfTitle)),
      body: books.when(
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
                onPressed: () => _showImportHint(context),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.importBook),
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final book = items[index];
              return ListTile(
                title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(book.author ?? book.formatId),
                trailing: Text('${book.chapterCount} 章'),
              );
            },
          );
        },
      ),
    );
  }

  void _showImportHint(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.importComingSoon)));
  }
}
