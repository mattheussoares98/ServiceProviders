part of 'company_cubit.dart';

class CompanyState extends BaseState {
  const CompanyState({
    super.status,
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
      permissionGroups = const [];

  final CompanyEntity? company;
  final List<CompanyEntity> companies;
  final String? selectedCompanyId;
  final CompanyParameterEntity? parameters;
  final List<PermissionGroupEntity> permissionGroups;

  CompanyState copyWith({
    StateStatus? status,
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
      status: status ?? this.status,
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
    status,
    company,
    companies,
    selectedCompanyId,
    parameters,
    permissionGroups,
  ];
}
