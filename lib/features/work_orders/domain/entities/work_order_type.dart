enum WorkOrderType {
  corrective('corrective'),
  preventive('preventive'),
  inspection('inspection');

  const WorkOrderType(this.code);
  final String code;

  static WorkOrderType fromCode(String code) {
    for (final val in WorkOrderType.values) {
      if (val.code == code) return val;
    }
    return WorkOrderType.corrective;
  }
}
