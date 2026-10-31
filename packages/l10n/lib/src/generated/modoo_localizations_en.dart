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
  String get readerParagraphSpacing => 'Paragraph spacing';

  @override
  String get readerMargin => 'Margins';

  @override
  String get readerFont => 'Font';

  @override
  String get readerFontSystem => 'Default';

  @override
  String get readerFontSerif => 'Serif';

  @override
  String get readerFontMono => 'Mono';

  @override
  String get readerTextAlign => 'Alignment';

  @override
  String get readerAlignStart => 'Left';

  @override
  String get readerAlignJustify => 'Justified';

  @override
  String get readerPageTurn => 'Page turn';

  @override
  String get pageTurnSlide => 'Horizontal';

  @override
  String get pageTurnVertical => 'Vertical';

  @override
  String get pageTurnHorizontal => 'Horizontal';

  @override
  String get listen => 'Listen';

  @override
  String get listenComingSoon => 'Text to speech arrives with the plugin SDK (M4)';

  @override
  String get pageTurnNone => 'None';

  @override
  String get pageTurnCover => 'Cover';

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
  String get annotationsTitle => 'Notes';

  @override
  String get annotationsThisPage => 'Notes on this page';

  @override
  String get annotationHint => 'Write down your thoughts';

  @override
  String get annotationSaved => 'Note saved';

  @override
  String get annotationDeleted => 'Note deleted';

  @override
  String get noAnnotations => 'No notes yet';

  @override
  String get editAnnotation => 'Edit note';

  @override
  String paragraphNumber(int index) {
    return 'Paragraph $index';
  }

  @override
  String get statsTitle => 'Reading stats';

  @override
  String get statsToday => 'Today';

  @override
  String get statsWeek => 'Last 7 days';

  @override
  String get statsTotal => 'All time';

  @override
  String get statsStreak => 'Streak';

  @override
  String get statsCharacters => 'Characters';

  @override
  String statsMinutes(int count) {
    return '$count min';
  }

  @override
  String statsHours(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String statsStreakDays(int days) {
    return '$days days';
  }

  @override
  String statsCharactersCount(int count) {
    return '$count chars';
  }

  @override
  String get statsEmpty => 'No reading yet. Read for a while and it shows up here.';

  @override
  String get statsLastDays => 'Last 7 days';

  @override
  String get errorGeneric => 'Something went wrong';
}
