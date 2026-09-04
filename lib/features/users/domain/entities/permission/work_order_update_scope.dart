enum WorkOrderUpdateScope {
  all('all'),
  assigned('assigned'),
  own('own'),
  none('none');

  const WorkOrderUpdateScope(this.code);
  final String code;

  static WorkOrderUpdateScope fromCode(String? code) {
    return WorkOrderUpdateScope.values.firstWhere(
      (e) => e.code == code,
      orElse: () => WorkOrderUpdateScope.none,
    );
  }
}
