part of 'company_cubit.dart';

class CompanyState extends BaseState {
  const CompanyState({
    super.sections = const {},
    this.company,
    this.companies = const [],
    this.selectedCompanyId,
    this.parameters,
    this.permissionGroups = const [],
  });

  const CompanyState.initial()
    : company = null,
      companies = const [],
      selectedCompanyId = null,
      parameters = null,
      permissionGroups = const [],
      super(sections: const {});

  final CompanyEntity? company;
  final List<CompanyEntity> companies;
  final String? selectedCompanyId;
  final CompanyParameterEntity? parameters;
  final List<PermissionGroupEntity> permissionGroups;

  CompanyState copyWith({
    Map<SectionKey, SectionState>? sections,
    CompanyEntity? company,
    List<CompanyEntity>? companies,
    String? selectedCompanyId,
    CompanyParameterEntity? parameters,
    List<PermissionGroupEntity>? permissionGroups,
    bool annulCompany = false,
    bool annulSelectedCompanyId = false,
    bool annulParameters = false,
  }) {
    return CompanyState(
      sections: sections ?? this.sections,
      company: annulCompany ? null : company ?? this.company,
      companies: companies ?? this.companies,
      selectedCompanyId: annulSelectedCompanyId
          ? null
          : selectedCompanyId ?? this.selectedCompanyId,
      parameters: annulParameters ? null : parameters ?? this.parameters,
      permissionGroups: permissionGroups ?? this.permissionGroups,
    );
  }

  @override
  List<Object?> get props => [
    sections,
    company,
    companies,
    selectedCompanyId,
    parameters,
    permissionGroups,
  ];
}
