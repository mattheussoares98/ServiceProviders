enum WorkOrderType {
  corrective('corrective', 'Corretiva'),
  preventive('preventive', 'Preventiva'),
  inspection('inspection', 'Inspeção');

  const WorkOrderType(this.code, this.label);
  final String code;
  final String label;

  static WorkOrderType fromCode(String code) {
    for (final val in WorkOrderType.values) {
      if (val.code == code) return val;
    }
    return WorkOrderType.corrective;
  }
}
