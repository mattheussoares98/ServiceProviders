enum PauseRequestStatus {
  pending('pending', 'Pendente'),
  approved('approved', 'Aprovado'),
  rejected('rejected', 'Rejeitado'),
  cancelled('cancelled', 'Cancelado');

  const PauseRequestStatus(this.value, this.label);
  final String value;
  final String label;

  static PauseRequestStatus fromValue(String value) {
    for (final val in PauseRequestStatus.values) {
      if (val.value == value) return val;
    }
    if (value == 'cancelled_by_provider') return PauseRequestStatus.cancelled;
    return PauseRequestStatus.pending;
  }
}
