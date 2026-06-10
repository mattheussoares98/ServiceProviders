import 'package:clean_architecture/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class CompanyCubitUseCases {
  const CompanyCubitUseCases({required this.createCompany});

  final CreateCompanyUseCase createCompany;
}
