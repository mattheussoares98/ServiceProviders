enum PermissionAction {
  create('create'),
  read('read'),
  update('update'),
  delete('delete');

  const PermissionAction(this.code);
  final String code;

  static PermissionAction? fromCode(String code) {
    for (final val in PermissionAction.values) {
      if (val.code == code) return val;
    }
    return null;
  }
}
