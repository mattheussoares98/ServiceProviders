import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_use_case.dart';

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
