enum SyncStatus {
  pending('pending'),
  syncing('syncing'),
  failed('failed'),
  completed('completed');

  const SyncStatus(this.code);
  final String code;

  static SyncStatus fromCode(String code) => switch (code) {
    'pending' => SyncStatus.pending,
    'syncing' => SyncStatus.syncing,
    'failed' => SyncStatus.failed,
    'completed' => SyncStatus.completed,
    _ => SyncStatus.pending,
  };
}
