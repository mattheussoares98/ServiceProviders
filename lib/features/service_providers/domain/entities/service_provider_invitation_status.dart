enum ServiceProviderInvitationStatus {
  pending('pending', 'Pendente'),
  accepted('accepted', 'Aceito'),
  rejected('rejected', 'Rejeitado'),
  expired('expired', 'Expirado');

  const ServiceProviderInvitationStatus(this.value, this.label);
  final String value;
  final String label;

  static ServiceProviderInvitationStatus fromString(String value) {
    return ServiceProviderInvitationStatus.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => ServiceProviderInvitationStatus.pending,
    );
  }
}
