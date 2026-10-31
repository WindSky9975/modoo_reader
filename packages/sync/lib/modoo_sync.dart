/// Sync support: the WebDAV layout and the conflict rule.
///
/// Sync is opt-in and only ever uploads progress and bookmarks, never book
/// files (DEVELOPMENT_PLAN §3.8).
library;

export 'src/conflict_resolver.dart';
export 'src/webdav_path.dart';
