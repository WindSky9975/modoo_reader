/// Remote layout for one user account.
///
/// ```
/// /modoo_reader/
///   progress/<deviceId>.json
///   bookmarks/<deviceId>.json
/// ```
const String syncRoot = 'modoo_reader';

/// Joins path segments with a single `/` and trims duplicates.
String joinPath(String base, [String? child]) {
  final segments = <String>[
    ...base.split('/').where((String s) => s.isNotEmpty),
    if (child != null) ...child.split('/').where((String s) => s.isNotEmpty),
  ];
  return '/${segments.join('/')}';
}

/// Remote path of one device's progress file.
String progressPath(String deviceId) => joinPath(syncRoot, 'progress/$deviceId.json');

/// Remote path of one device's bookmarks file.
String bookmarksPath(String deviceId) => joinPath(syncRoot, 'bookmarks/$deviceId.json');
