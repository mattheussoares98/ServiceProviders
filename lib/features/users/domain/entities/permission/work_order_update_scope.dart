enum WorkOrderUpdateScope {
  all('all', 'Todos'),
  assigned('assigned', 'Atribuídos'),
  own('own', 'Criados por mim'),
  none('none', 'Nenhum');

  const WorkOrderUpdateScope(this.code, this.label);
  final String code;
  final String label;

  static WorkOrderUpdateScope fromCode(String? code) {
    return WorkOrderUpdateScope.values.firstWhere(
      (e) => e.code == code,
      orElse: () => WorkOrderUpdateScope.none,
    );
  }
}
