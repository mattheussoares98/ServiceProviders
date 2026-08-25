part of 'company_cubit.dart';

class CompanyState extends BaseState {
  const CompanyState({
    super.status,
    this.company,
    this.companies = const [],
    this.selectedCompanyId,
  });

  const CompanyState.initial()
    : company = null,
      companies = const [],
      selectedCompanyId = null;

  final CompanyEntity? company;
  final List<CompanyEntity> companies;
  final String? selectedCompanyId;

  CompanyState copyWith({
    StateStatus? status,
    CompanyEntity? company,
    List<CompanyEntity>? companies,
    String? selectedCompanyId,
    bool annulCompany = false,
    bool annulSelectedCompanyId = false,
  }) {
    return CompanyState(
      status: status ?? this.status,
      company: annulCompany ? null : company ?? this.company,
      companies: companies ?? this.companies,
      selectedCompanyId: annulSelectedCompanyId
          ? null
          : selectedCompanyId ?? this.selectedCompanyId,
    );
  }

  @override
  List<Object?> get props => [status, company, companies, selectedCompanyId];
}
