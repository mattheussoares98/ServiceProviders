import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:clean_architecture/features/company/domain/use_cases/get_company_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class CompanyCubitUseCases {
  const CompanyCubitUseCases({
    required this.createCompany,
    required this.getSessionUser,
    required this.getCompany,
  });

  final CreateCompanyUseCase createCompany;
  final GetSessionUserUseCase getSessionUser;
  final GetCompanyUseCase getCompany;
}
