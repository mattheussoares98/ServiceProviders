part of 'service_providers_cubit.dart';

class ServiceProvidersState extends BaseState {
  const ServiceProvidersState({
    required this.companies,
    required this.profiles,
    this.invitations = const {},
    this.loadingCompanyIds = const {},
    this.selectedCompanyId,
    this.selectedProfileId,
    super.sections = const {},
  });

  const ServiceProvidersState.initial()
    : companies = const [],
      profiles = const {},
      invitations = const {},
      loadingCompanyIds = const {},
      selectedCompanyId = null,
      selectedProfileId = null,
      super(sections: const {});

  final List<ServiceProviderCompanyEntity> companies;
  final Map<String, List<ServiceProviderProfileEntity>> profiles;
  final Map<String, List<ServiceProviderInvitationEntity>> invitations;
  final Set<String> loadingCompanyIds;
  final String? selectedCompanyId;
  final String? selectedProfileId;

  ServiceProvidersState copyWith({
    List<ServiceProviderCompanyEntity>? companies,
    Map<String, List<ServiceProviderProfileEntity>>? profiles,
    Map<String, List<ServiceProviderInvitationEntity>>? invitations,
    Set<String>? loadingCompanyIds,
    Map<SectionKey, SectionState>? sections,
    String? selectedCompanyId,
    String? selectedProfileId,
    bool annulCompanyId = false,
    bool annulProfileId = false,
  }) {
    return ServiceProvidersState(
      companies: companies ?? this.companies,
      profiles: profiles ?? this.profiles,
      invitations: invitations ?? this.invitations,
      loadingCompanyIds: loadingCompanyIds ?? this.loadingCompanyIds,
      sections: sections ?? this.sections,
      selectedCompanyId: annulCompanyId
          ? null
          : selectedCompanyId ?? this.selectedCompanyId,
      selectedProfileId: annulProfileId
          ? null
          : selectedProfileId ?? this.selectedProfileId,
    );
  }

  @override
  List<Object?> get props => [
    companies,
    profiles,
    invitations,
    loadingCompanyIds,
    sections,
    selectedCompanyId,
    selectedProfileId,
  ];
}
