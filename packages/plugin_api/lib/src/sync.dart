import 'dart:typed_data';

/// A sync transport. M5 ships exactly one implementation (WebDAV); the
/// interface exists so tests and future backends do not reshape callers
/// (DEVELOPMENT_PLAN §3.8).
abstract interface class SyncBackend {
  String get backendId;

  /// Cheap round-trip used by the settings page's "test connection" button.
  Future<bool> testConnection();

  /// Remote snapshot description, used to detect conflicts before upload.
  Future<SyncManifest> fetchManifest();

  Future<void> upload(String remotePath, Uint8List bytes, {String? ifMatchEtag});

  /// Returns null when the remote file does not exist.
  Future<Uint8List?> download(String remotePath);
}

/// Remote state at the last successful round trip.
final class SyncManifest {
  const SyncManifest({required this.etag, required this.deviceId, required this.updatedAt});

  final String etag;
  final String deviceId;
  final DateTime updatedAt;
}
