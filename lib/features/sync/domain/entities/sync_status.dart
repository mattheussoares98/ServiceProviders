enum SyncStatus {
  pending('pending'),
  syncing('syncing'),
  failed('failed'),
  deadLetter('dead_letter'),
  cancelled('cancelled'),
  completed('completed');

  const SyncStatus(this.code);
  final String code;

  static SyncStatus fromCode(String code) => switch (code) {
    'pending' => SyncStatus.pending,
    'syncing' => SyncStatus.syncing,
    'failed' => SyncStatus.failed,
    'dead_letter' => SyncStatus.deadLetter,
    'cancelled' => SyncStatus.cancelled,
    'completed' => SyncStatus.completed,
    _ => SyncStatus.pending,
  };
}
