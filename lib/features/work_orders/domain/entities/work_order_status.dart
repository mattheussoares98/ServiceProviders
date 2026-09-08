enum WorkOrderStatus {
  open('open'),
  inProgress('in_progress'),
  onHold('on_hold'),
  pendingConclusionApproval('pending_conclusion'),
  completed('completed'),
  cancelled('cancelled');

  const WorkOrderStatus(this.code);
  final String code;

  bool get isOpen => this == WorkOrderStatus.open;
  bool get isCompleted => this == WorkOrderStatus.completed;
  bool get isCancelled => this == WorkOrderStatus.cancelled;
  bool get isPaused => this == WorkOrderStatus.onHold;
  bool get isPendingConclusionApproval =>
      this == WorkOrderStatus.pendingConclusionApproval;

  bool get isPendingApproval => isPendingConclusionApproval;

  bool get isRunning => this == WorkOrderStatus.inProgress || isPendingApproval;

  bool get showsExecutionTimer => isRunning || isPaused;

  bool get showsBottomActions => isOpen || isRunning || isPaused;

  bool get acceptsAttachments => this == WorkOrderStatus.inProgress;

  static WorkOrderStatus fromCode(String code) {
    for (final val in WorkOrderStatus.values) {
      if (val.code == code) return val;
    }
    return WorkOrderStatus.open;
  }
}
