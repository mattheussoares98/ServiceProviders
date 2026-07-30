enum ServiceProviderInvitationStatus {
  pending('pending', 'Convite pendente'),
  accepted('accepted', 'Convite aceito'),
  rejected('rejected', 'Convite rejeitado'),
  expired('expired', 'Convite expirado');

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
