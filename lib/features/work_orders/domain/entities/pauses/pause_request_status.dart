enum PauseRequestStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  cancelled('cancelled');

  const PauseRequestStatus(this.value);
  final String value;

  static PauseRequestStatus fromValue(String value) {
    for (final val in PauseRequestStatus.values) {
      if (val.value == value) return val;
    }
    if (value == 'cancelled_by_provider') return PauseRequestStatus.cancelled;
    return PauseRequestStatus.pending;
  }
}
