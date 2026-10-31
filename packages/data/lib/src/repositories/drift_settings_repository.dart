import 'dart:convert';

import 'package:modoo_domain/modoo_domain.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

/// Drift-backed [SettingsRepository].
///
/// One JSON row per feature area (`reader` today), so adding a preference does
/// not need a migration. Corrupt values fall back to defaults instead of
/// blocking startup.
final class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  static const String _readerKey = 'reader';

  @override
  Future<ReaderSettings> read() async {
    final SettingRow? row = await (_db.select(
      _db.appSettings,
    )..where((AppSettings table) => table.key.equals(_readerKey))).getSingleOrNull();
    if (row == null) return ReaderSettings.defaults;
    final Object? decoded = jsonDecode(row.value);
    if (decoded is! Map<String, Object?>) return ReaderSettings.defaults;
    return ReaderSettings(
      fontSize: _double(decoded['fontSize'], ReaderSettings.defaults.fontSize),
      lineHeight: _double(decoded['lineHeight'], ReaderSettings.defaults.lineHeight),
      themeId: _string(decoded['themeId'], ReaderSettings.defaults.themeId),
      pageTurnId: _string(decoded['pageTurnId'], ReaderSettings.defaults.pageTurnId),
    ).normalized();
  }

  @override
  Future<void> save(ReaderSettings settings) async {
    final ReaderSettings value = settings.normalized();
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _readerKey,
            value: jsonEncode(<String, Object?>{
              'fontSize': value.fontSize,
              'lineHeight': value.lineHeight,
              'themeId': value.themeId,
              'pageTurnId': value.pageTurnId,
            }),
          ),
        );
  }

  static double _double(Object? raw, double fallback) => raw is num ? raw.toDouble() : fallback;

  static String _string(Object? raw, String fallback) =>
      raw is String && raw.isNotEmpty ? raw : fallback;
}
