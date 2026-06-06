enum WorkOrderStatus {
  open('open'),
  inProgress('in_progress'),
  onHold('on_hold'),
  completed('completed'),
  cancelled('cancelled');

  const WorkOrderStatus(this.code);
  final String code;

  static WorkOrderStatus fromCode(String code) {
    for (final val in WorkOrderStatus.values) {
      if (val.code == code) return val;
    }
    return WorkOrderStatus.open;
  }
}
