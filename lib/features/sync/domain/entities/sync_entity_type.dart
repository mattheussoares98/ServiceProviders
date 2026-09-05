enum SyncEntityType {
  workOrder('work_order'),
  task('task'),
  observation('observation'),
  pauseRequest('pause_request'),
  attachment('attachment'),
  accessLog('access_log');

  const SyncEntityType(this.code);
  final String code;

  static SyncEntityType fromCode(String code) => switch (code) {
    'work_order' => SyncEntityType.workOrder,
    'task' => SyncEntityType.task,
    'observation' => SyncEntityType.observation,
    'pause_request' => SyncEntityType.pauseRequest,
    'attachment' => SyncEntityType.attachment,
    'access_log' => SyncEntityType.accessLog,
    _ => SyncEntityType.workOrder,
  };
}
