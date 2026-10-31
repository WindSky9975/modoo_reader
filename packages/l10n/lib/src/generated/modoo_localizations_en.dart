// GENERATED CODE - DO NOT MODIFY BY HAND. Run: melos run gen:l10n

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'modoo_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ModooLocalizationsEn extends ModooLocalizations {
  ModooLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Modoo';

  @override
  String get bookshelfTitle => 'Shelf';

  @override
  String get bookshelfEmptyTitle => 'No books yet';

  @override
  String get bookshelfEmptyMessage => 'Import a TXT or EPUB file to start reading.';

  @override
  String get importBook => 'Import book';

  @override
  String get importInProgress => 'Importing…';

  @override
  String importSucceeded(String title, int count) {
    return 'Imported \"$title\" with $count chapters';
  }

  @override
  String get importUnsupportedFormat => 'This file format is not supported yet.';

  @override
  String get importParseFailed => 'The file could not be parsed; it may be damaged.';

  @override
  String get importStorageFailed => 'Could not save the file. Check the free space.';

  @override
  String get importFailedGeneric => 'Import failed. Please try again.';

  @override
  String chaptersCount(int count) {
    return '$count chapters';
  }

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteBookTitle => 'Remove this book?';

  @override
  String deleteBookMessage(String title) {
    return '\"$title\" will be removed from the shelf. The file stays on disk.';
  }

  @override
  String get tocTitle => 'Contents';

  @override
  String get readerSettings => 'Typography';

  @override
  String get readerFontSize => 'Font size';

  @override
  String get readerLineHeight => 'Line height';

  @override
  String get readerPageTurn => 'Page turn';

  @override
  String get pageTurnSlide => 'Slide';

  @override
  String get pageTurnNone => 'None';

  @override
  String get previousChapter => 'Previous';

  @override
  String get nextChapter => 'Next';

  @override
  String get endOfChapter => 'End of the book';

  @override
  String get bookmarksTitle => 'Bookmarks';

  @override
  String get addBookmark => 'Bookmark this page';

  @override
  String get bookmarkAdded => 'Bookmark added';

  @override
  String get bookmarkDeleted => 'Bookmark deleted';

  @override
  String get bookmarkNoteHint => 'Note (optional)';

  @override
  String get noBookmarks => 'No bookmarks yet';

  @override
  String get save => 'Save';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search this book';

  @override
  String get searchNoResults => 'No matches';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get themePaper => 'Paper';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get themeNight => 'Night';

  @override
  String get themeAmoled => 'Black';

  @override
  String get retry => 'Retry';

  @override
  String get errorGeneric => 'Something went wrong';
}
