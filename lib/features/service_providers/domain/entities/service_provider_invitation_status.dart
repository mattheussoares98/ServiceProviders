enum ServiceProviderInvitationStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  expired('expired');

  const ServiceProviderInvitationStatus(this.value);
  final String value;

  static ServiceProviderInvitationStatus fromString(String value) {
    return ServiceProviderInvitationStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => ServiceProviderInvitationStatus.pending,
    );
  }
}
