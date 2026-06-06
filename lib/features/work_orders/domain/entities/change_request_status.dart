enum ChangeRequestStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const ChangeRequestStatus(this.code);
  final String code;

  static ChangeRequestStatus fromCode(String code) {
    for (final val in ChangeRequestStatus.values) {
      if (val.code == code) return val;
    }
    return ChangeRequestStatus.pending;
  }
}
