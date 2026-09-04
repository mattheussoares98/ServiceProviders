enum WorkOrderReadScope {
  all('all'),
  assigned('assigned');

  const WorkOrderReadScope(this.code);
  final String code;

  static WorkOrderReadScope fromCode(String? code) {
    return WorkOrderReadScope.values.firstWhere(
      (e) => e.code == code,
      orElse: () => WorkOrderReadScope.assigned,
    );
  }
}
