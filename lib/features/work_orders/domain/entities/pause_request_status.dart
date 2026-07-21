enum PauseRequestStatus {
  pending('pending', 'Pendente'),
  approved('approved', 'Aprovado'),
  rejected('rejected', 'Rejeitado'),
  cancelledByProvider('cancelled_by_provider', 'Cancelado pelo prestador');

  const PauseRequestStatus(this.value, this.label);
  final String value;
  final String label;

  static PauseRequestStatus fromValue(String value) {
    for (final val in PauseRequestStatus.values) {
      if (val.value == value) return val;
    }
    return PauseRequestStatus.pending;
  }
}
