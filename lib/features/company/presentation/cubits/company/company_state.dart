part of 'company_cubit.dart';

class CompanyState extends BaseState {
  const CompanyState({super.status, this.company});

  const CompanyState.initial() : company = null;

  final CompanyEntity? company;

  CompanyState copyWith({
    StateStatus? status,
    CompanyEntity? company,
    bool annulCompany = false,
  }) {
    return CompanyState(
      status: status ?? this.status,
      company: annulCompany ? null : company ?? this.company,
    );
  }

  @override
  List<Object?> get props => [status, company];
}
