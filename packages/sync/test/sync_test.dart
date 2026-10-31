import 'package:modoo_sync/modoo_sync.dart';
import 'package:test/test.dart';

void main() {
  group('resolveProgressConflict', () {
    final base = DateTime.utc(2026, 10, 31, 12);

    test('higher revision wins', () {
      expect(
        resolveProgressConflict(
          localRevision: 3,
          remoteRevision: 2,
          localUpdatedAt: base,
          remoteUpdatedAt: base,
        ),
        SyncChoice.keepLocal,
      );
      expect(
        resolveProgressConflict(
          localRevision: 1,
          remoteRevision: 4,
          localUpdatedAt: base.add(const Duration(days: 1)),
          remoteUpdatedAt: base,
        ),
        SyncChoice.keepRemote,
      );
    });

    test('equal revision falls back to the newer timestamp', () {
      expect(
        resolveProgressConflict(
          localRevision: 2,
          remoteRevision: 2,
          localUpdatedAt: base.add(const Duration(minutes: 5)),
          remoteUpdatedAt: base,
        ),
        SyncChoice.keepLocal,
      );
      expect(
        resolveProgressConflict(
          localRevision: 2,
          remoteRevision: 2,
          localUpdatedAt: base,
          remoteUpdatedAt: base.add(const Duration(minutes: 5)),
        ),
        SyncChoice.keepRemote,
      );
    });

    test('identical revision and timestamp keeps both', () {
      expect(
        resolveProgressConflict(
          localRevision: 2,
          remoteRevision: 2,
          localUpdatedAt: base,
          remoteUpdatedAt: base,
        ),
        SyncChoice.keepBoth,
      );
    });
  });

  group('webdav paths', () {
    test('joinPath normalizes slashes', () {
      expect(joinPath('/modoo/', '/a/b/'), '/modoo/a/b');
      expect(joinPath('modoo'), '/modoo');
    });

    test('per-device files are distinct', () {
      expect(progressPath('phone-1'), '/modoo_reader/progress/phone-1.json');
      expect(bookmarksPath('tablet'), '/modoo_reader/bookmarks/tablet.json');
      expect(progressPath('a') == progressPath('b'), isFalse);
    });
  });
}
