enum WorkOrderStatus {
  open('open', 'Aberta'),
  inProgress('in_progress', 'Em andamento'),
  pendingPauseApproval('pending_pause', 'Em pausa'),
  onHold('on_hold', 'Em pausa'),
  pendingConclusionApproval(
    'pending_conclusion',
    'Conclusão pendente de aprovação',
  ),
  completed('completed', 'Concluída'),
  cancelled('cancelled', 'Cancelada');

  const WorkOrderStatus(this.code, this.label);
  final String code;
  final String label;

  bool get isOpen => this == WorkOrderStatus.open;
  bool get isCompleted => this == WorkOrderStatus.completed;
  bool get isCancelled => this == WorkOrderStatus.cancelled;
  bool get isPaused => this == WorkOrderStatus.onHold || isPendingPauseApproval;
  bool get isPendingPauseApproval =>
      this == WorkOrderStatus.pendingPauseApproval;
  bool get isPendingConclusionApproval =>
      this == WorkOrderStatus.pendingConclusionApproval;

  bool get isPendingApproval =>
      isPendingPauseApproval || isPendingConclusionApproval;

  bool get isRunning => this == WorkOrderStatus.inProgress || isPendingApproval;

  bool get showsExecutionTimer => isRunning || isPaused;

  bool get showsBottomActions => isRunning || isPaused;

  static WorkOrderStatus fromCode(String code) {
    for (final val in WorkOrderStatus.values) {
      if (val.code == code) return val;
    }
    return WorkOrderStatus.open;
  }
}
