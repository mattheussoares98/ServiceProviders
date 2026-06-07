enum WorkOrderStatus {
  open('open', 'Aberta'),
  inProgress('in_progress', 'Em Andamento'),
  onHold('on_hold', 'Em Espera'),
  completed('completed', 'Concluída'),
  cancelled('cancelled', 'Cancelada');

  const WorkOrderStatus(this.code, this.label);
  final String code;
  final String label;

  static WorkOrderStatus fromCode(String code) {
    for (final val in WorkOrderStatus.values) {
      if (val.code == code) return val;
    }
    return WorkOrderStatus.open;
  }
}
