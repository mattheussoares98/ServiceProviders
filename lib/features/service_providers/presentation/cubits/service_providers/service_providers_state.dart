part of 'service_providers_cubit.dart';

class ServiceProvidersState extends BaseState {
  const ServiceProvidersState({
    required this.companies,
    required this.profiles,
    this.invitations = const {},
    this.selectedCompanyId,
    this.selectedProfileId,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const ServiceProvidersState.initial()
    : companies = const [],
      profiles = const {},
      invitations = const {},
      selectedCompanyId = null,
      selectedProfileId = null,
      super(status: StateStatus.initial, errorMessage: '');

  final List<ServiceProviderCompanyEntity> companies;
  final Map<String, List<ServiceProviderProfileEntity>> profiles;
  final Map<String, List<ServiceProviderInvitationEntity>> invitations;
  final String? selectedCompanyId;
  final String? selectedProfileId;

  ServiceProvidersState copyWith({
    List<ServiceProviderCompanyEntity>? companies,
    Map<String, List<ServiceProviderProfileEntity>>? profiles,
    Map<String, List<ServiceProviderInvitationEntity>>? invitations,
    String? selectedCompanyId,
    String? selectedProfileId,
    StateStatus? status,
    String? errorMessage,
    bool annulCompanyId = false,
    bool annulProfileId = false,
  }) {
    return ServiceProvidersState(
      companies: companies ?? this.companies,
      profiles: profiles ?? this.profiles,
      invitations: invitations ?? this.invitations,
      selectedCompanyId: annulCompanyId
          ? null
          : selectedCompanyId ?? this.selectedCompanyId,
      selectedProfileId: annulProfileId
          ? null
          : selectedProfileId ?? this.selectedProfileId,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    companies,
    profiles,
    invitations,
    selectedCompanyId,
    selectedProfileId,
    status,
    errorMessage,
  ];
}
