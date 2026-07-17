enum WorkOrderReadScope {
  all('all', 'Todos'),
  assigned('assigned', 'Atribuídos');

  const WorkOrderReadScope(this.code, this.label);
  final String code;
  final String label;

  static WorkOrderReadScope fromCode(String? code) {
    return WorkOrderReadScope.values.firstWhere(
      (e) => e.code == code,
      orElse: () => WorkOrderReadScope.assigned,
    );
  }
}
