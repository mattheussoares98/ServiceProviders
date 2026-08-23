enum SyncOperationType {
  create('create'),
  update('update'),
  delete('delete');

  const SyncOperationType(this.code);
  final String code;

  static SyncOperationType fromCode(String code) => switch (code) {
    'create' => SyncOperationType.create,
    'update' => SyncOperationType.update,
    'delete' => SyncOperationType.delete,
    _ => SyncOperationType.create,
  };
}
