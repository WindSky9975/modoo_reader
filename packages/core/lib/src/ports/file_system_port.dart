import 'dart:typed_data';

/// File access seam.
///
/// Shared packages must not import `dart:io` (they also target Web later), so
/// file work goes through this port and is implemented at the app edge.
abstract interface class FileSystemPort {
  Future<bool> exists(String path);

  /// Size in bytes.
  Future<int> length(String path);

  Future<Uint8List> readBytes(String path);

  /// Streaming read, the only way large books are touched.
  Stream<List<int>> openRead(String path);
}
