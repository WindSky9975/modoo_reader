/// What to do when the local and remote progress disagree.
enum SyncChoice {
  /// The local copy wins and is uploaded.
  keepLocal,

  /// The remote copy wins and is written locally.
  keepRemote,

  /// Both are kept: the newer one becomes current, the other stays as history.
  keepBoth,
}

/// Server clocks and client clocks disagree, so revision is the primary key
/// and the timestamp only breaks ties.
SyncChoice resolveProgressConflict({
  required int localRevision,
  required int remoteRevision,
  required DateTime localUpdatedAt,
  required DateTime remoteUpdatedAt,
}) {
  if (localRevision != remoteRevision) {
    return localRevision > remoteRevision ? SyncChoice.keepLocal : SyncChoice.keepRemote;
  }
  final localMs = localUpdatedAt.toUtc().millisecondsSinceEpoch;
  final remoteMs = remoteUpdatedAt.toUtc().millisecondsSinceEpoch;
  if (localMs != remoteMs) {
    return localMs > remoteMs ? SyncChoice.keepLocal : SyncChoice.keepRemote;
  }
  return SyncChoice.keepBoth;
}
