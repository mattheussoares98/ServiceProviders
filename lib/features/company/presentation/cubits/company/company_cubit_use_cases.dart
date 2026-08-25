import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_selected_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_all_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/update_company_logo_use_case.dart';

@LazySingleton()
class CompanyCubitUseCases {
  const CompanyCubitUseCases({
    required this.createCompany,
    required this.getSessionUser,
    required this.getActiveCompanyId,
    required this.getCompany,
    required this.getAllCompanies,
    required this.setSelectedCompanyId,
    required this.updateCompanyLogo,
    required this.pickAttachment,
  });

  final CreateCompanyUseCase createCompany;
  final GetSessionUserUseCase getSessionUser;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetCompanyUseCase getCompany;
  final GetAllCompaniesUseCase getAllCompanies;
  final SetSelectedCompanyIdUseCase setSelectedCompanyId;
  final UpdateCompanyLogoUseCase updateCompanyLogo;
  final PickAttachmentUseCase pickAttachment;
}
