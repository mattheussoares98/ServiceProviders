enum SyncEntityType {
  workOrder('work_order'),
  task('task'),
  observation('observation'),
  pauseRequest('pause_request'),
  attachment('attachment');

  const SyncEntityType(this.code);
  final String code;

  static SyncEntityType fromCode(String code) => switch (code) {
    'work_order' => SyncEntityType.workOrder,
    'task' => SyncEntityType.task,
    'observation' => SyncEntityType.observation,
    'pause_request' => SyncEntityType.pauseRequest,
    'attachment' => SyncEntityType.attachment,
    _ => SyncEntityType.workOrder,
  };
}
