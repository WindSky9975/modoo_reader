// GENERATED CODE - DO NOT MODIFY BY HAND. Run: melos run gen:l10n

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'modoo_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class ModooLocalizationsZh extends ModooLocalizations {
  ModooLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '墨读';

  @override
  String get bookshelfTitle => '书架';

  @override
  String get bookshelfEmptyTitle => '还没有书';

  @override
  String get bookshelfEmptyMessage => '导入一个 TXT 或 EPUB 文件开始阅读。';

  @override
  String get importBook => '导入书籍';

  @override
  String get importInProgress => '正在导入…';

  @override
  String importSucceeded(String title, int count) {
    return '已导入《$title》，共 $count 章';
  }

  @override
  String get importUnsupportedFormat => '这个文件格式暂时不支持。';

  @override
  String get importParseFailed => '文件内容解析失败，文件可能已损坏。';

  @override
  String get importStorageFailed => '保存文件失败，请检查存储空间。';

  @override
  String get importFailedGeneric => '导入失败，请重试。';

  @override
  String chaptersCount(int count) {
    return '$count 章';
  }

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get deleteBookTitle => '移除这本书？';

  @override
  String deleteBookMessage(String title) {
    return '《$title》会从书架移除，文件本身不会被删除。';
  }

  @override
  String get tocTitle => '目录';

  @override
  String get readerSettings => '排版';

  @override
  String get readerFontSize => '字号';

  @override
  String get readerLineHeight => '行距';

  @override
  String get readerPageTurn => '翻页';

  @override
  String get pageTurnSlide => '左右';

  @override
  String get pageTurnVertical => '上下';

  @override
  String get pageTurnHorizontal => '左右';

  @override
  String get listen => '听书';

  @override
  String get listenComingSoon => '听书将在 M4 插件 SDK 之后提供';

  @override
  String get pageTurnNone => '无动画';

  @override
  String get previousChapter => '上一章';

  @override
  String get nextChapter => '下一章';

  @override
  String get endOfChapter => '本章结束';

  @override
  String get bookmarksTitle => '书签';

  @override
  String get addBookmark => '添加书签';

  @override
  String get bookmarkAdded => '已添加书签';

  @override
  String get bookmarkDeleted => '书签已删除';

  @override
  String get bookmarkNoteHint => '备注（可选）';

  @override
  String get noBookmarks => '还没有书签';

  @override
  String get save => '保存';

  @override
  String get searchTitle => '搜索';

  @override
  String get searchHint => '搜索本书';

  @override
  String get searchNoResults => '没有找到匹配的内容';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count 个结果');
    return '$_temp0';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsTheme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themePaper => '纸白';

  @override
  String get themeSepia => '米黄';

  @override
  String get themeNight => '夜间';

  @override
  String get themeAmoled => '纯黑';

  @override
  String get retry => '重试';

  @override
  String get errorGeneric => '出了点问题';
}
