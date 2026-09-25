import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_selected_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_permission_groups_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_profile_use_case.dart';

@LazySingleton()
class OnboardingCubitUseCases {
  const OnboardingCubitUseCases({
    required this.createCompany,
    required this.getPermissionGroups,
    required this.updateUserProfile,
    required this.getSessionUser,
    required this.saveUserData,
    required this.setSession,
    required this.setSelectedCompanyId,
    required this.localStorageClient,
    required this.sessionRepository,
  });

  final CreateCompanyUseCase createCompany;
  final GetPermissionGroupsUseCase getPermissionGroups;
  final UpdateUserProfileUseCase updateUserProfile;
  final GetSessionUserUseCase getSessionUser;
  final SaveUserDataUseCase saveUserData;
  final SetSessionUseCase setSession;
  final SetSelectedCompanyIdUseCase setSelectedCompanyId;
  final LocalStorageClient localStorageClient;
  final SessionRepository sessionRepository;
}
