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

  /// Shown when the import button is tapped before M1 ships.
  ///
  /// In zh, this message translates to:
  /// **'文件导入将在 M1 里程碑提供。'**
  String get importComingSoon;

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
