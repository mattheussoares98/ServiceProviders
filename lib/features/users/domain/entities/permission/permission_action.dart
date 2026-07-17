enum PermissionAction {
  create('create', 'Criar'),
  read('read', 'Pesquisar'),
  update('update', 'Alterar'),
  delete('delete', 'Excluir');

  const PermissionAction(this.code, this.label);
  final String code;
  final String label;

  static PermissionAction? fromCode(String code) {
    for (final val in PermissionAction.values) {
      if (val.code == code) return val;
    }
    return null;
  }
}
