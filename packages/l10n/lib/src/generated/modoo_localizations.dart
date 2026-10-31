// GENERATED CODE - DO NOT MODIFY BY HAND. Run: melos run gen:l10n
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'modoo_localizations_en.dart';
import 'modoo_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ModooLocalizations
/// returned by `ModooLocalizations.of(context)`.
///
/// Applications need to include `ModooLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/modoo_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ModooLocalizations.localizationsDelegates,
///   supportedLocales: ModooLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the ModooLocalizations.supportedLocales
/// property.
abstract class ModooLocalizations {
  ModooLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ModooLocalizations of(BuildContext context) {
    return Localizations.of<ModooLocalizations>(context, ModooLocalizations)!;
  }

  static const LocalizationsDelegate<ModooLocalizations> delegate = _ModooLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('zh')];

  /// Product name shown on the launcher and about page.
  ///
  /// In zh, this message translates to:
  /// **'墨读'**
  String get appName;

  /// Title of the shelf tab.
  ///
  /// In zh, this message translates to:
  /// **'书架'**
  String get bookshelfTitle;

  /// Empty shelf headline.
  ///
  /// In zh, this message translates to:
  /// **'还没有书'**
  String get bookshelfEmptyTitle;

  /// Empty shelf explanation.
  ///
  /// In zh, this message translates to:
  /// **'导入一个 TXT 或 EPUB 文件开始阅读。'**
  String get bookshelfEmptyMessage;

  /// Button that opens the file picker.
  ///
  /// In zh, this message translates to:
  /// **'导入书籍'**
  String get importBook;

  /// Shown while a picked file is being imported.
  ///
  /// In zh, this message translates to:
  /// **'正在导入…'**
  String get importInProgress;

  /// Confirmation after an import finished.
  ///
  /// In zh, this message translates to:
  /// **'已导入《{title}》，共 {count} 章'**
  String importSucceeded(String title, int count);

  /// Import failed: no plugin handles the extension.
  ///
  /// In zh, this message translates to:
  /// **'这个文件格式暂时不支持。'**
  String get importUnsupportedFormat;

  /// Import failed: the file was readable but invalid.
  ///
  /// In zh, this message translates to:
  /// **'文件内容解析失败，文件可能已损坏。'**
  String get importParseFailed;

  /// Import failed: copying the book into the library failed.
  ///
  /// In zh, this message translates to:
  /// **'保存文件失败，请检查存储空间。'**
  String get importStorageFailed;

  /// Import failed for an unexpected reason.
  ///
  /// In zh, this message translates to:
  /// **'导入失败，请重试。'**
  String get importFailedGeneric;

  /// Chapter count shown next to a shelf item.
  ///
  /// In zh, this message translates to:
  /// **'{count} 章'**
  String chaptersCount(int count);

  /// Destructive action label.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// Dismiss a dialog without doing anything.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// Confirmation dialog title for removing a book.
  ///
  /// In zh, this message translates to:
  /// **'移除这本书？'**
  String get deleteBookTitle;

  /// Confirmation dialog body; explains that the file stays.
  ///
  /// In zh, this message translates to:
  /// **'《{title}》会从书架移除，文件本身不会被删除。'**
  String deleteBookMessage(String title);

  /// Title of the table of contents sheet.
  ///
  /// In zh, this message translates to:
  /// **'目录'**
  String get tocTitle;

  /// Title of the reader typography sheet.
  ///
  /// In zh, this message translates to:
  /// **'排版'**
  String get readerSettings;

  /// Label of the font size slider.
  ///
  /// In zh, this message translates to:
  /// **'字号'**
  String get readerFontSize;

  /// Label of the line height slider.
  ///
  /// In zh, this message translates to:
  /// **'行距'**
  String get readerLineHeight;

  /// Label of the page turn mode selector.
  ///
  /// In zh, this message translates to:
  /// **'翻页'**
  String get readerPageTurn;

  /// Page turn mode: animated horizontal slide.
  ///
  /// In zh, this message translates to:
  /// **'滑动'**
  String get pageTurnSlide;

  /// Page turn mode: jump straight to the next page.
  ///
  /// In zh, this message translates to:
  /// **'无动画'**
  String get pageTurnNone;

  /// Jump to the previous chapter.
  ///
  /// In zh, this message translates to:
  /// **'上一章'**
  String get previousChapter;

  /// Jump to the next chapter.
  ///
  /// In zh, this message translates to:
  /// **'下一章'**
  String get nextChapter;

  /// Shown at the end of the last chapter.
  ///
  /// In zh, this message translates to:
  /// **'本章结束'**
  String get endOfChapter;

  /// Title of the bookmark list sheet.
  ///
  /// In zh, this message translates to:
  /// **'书签'**
  String get bookmarksTitle;

  /// Action that bookmarks the current page.
  ///
  /// In zh, this message translates to:
  /// **'添加书签'**
  String get addBookmark;

  /// Snack bar after bookmarking the current page.
  ///
  /// In zh, this message translates to:
  /// **'已添加书签'**
  String get bookmarkAdded;

  /// Snack bar after deleting a bookmark.
  ///
  /// In zh, this message translates to:
  /// **'书签已删除'**
  String get bookmarkDeleted;

  /// Placeholder of the bookmark note field.
  ///
  /// In zh, this message translates to:
  /// **'备注（可选）'**
  String get bookmarkNoteHint;

  /// Empty state of the bookmark list.
  ///
  /// In zh, this message translates to:
  /// **'还没有书签'**
  String get noBookmarks;

  /// Confirm button of dialogs that store input.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// Title of the settings tab.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// Label of the theme selector.
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get settingsTheme;

  /// Theme option: follow the platform setting.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// Theme option: white paper.
  ///
  /// In zh, this message translates to:
  /// **'纸白'**
  String get themePaper;

  /// Theme option: sepia.
  ///
  /// In zh, this message translates to:
  /// **'米黄'**
  String get themeSepia;

  /// Theme option: dark.
  ///
  /// In zh, this message translates to:
  /// **'夜间'**
  String get themeNight;

  /// Theme option: black background for OLED screens.
  ///
  /// In zh, this message translates to:
  /// **'纯黑'**
  String get themeAmoled;

  /// Generic retry button.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// Generic error headline; details stay in the log.
  ///
  /// In zh, this message translates to:
  /// **'出了点问题'**
  String get errorGeneric;
}

class _ModooLocalizationsDelegate extends LocalizationsDelegate<ModooLocalizations> {
  const _ModooLocalizationsDelegate();

  @override
  Future<ModooLocalizations> load(Locale locale) {
    return SynchronousFuture<ModooLocalizations>(lookupModooLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_ModooLocalizationsDelegate old) => false;
}

ModooLocalizations lookupModooLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return ModooLocalizationsEn();
    case 'zh':
      return ModooLocalizationsZh();
  }

  throw FlutterError(
    'ModooLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
