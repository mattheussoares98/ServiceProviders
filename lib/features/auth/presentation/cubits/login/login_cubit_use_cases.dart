import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/use_cases/create_access_log_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/login_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';

@LazySingleton()
class LoginCubitUseCases {
  const LoginCubitUseCases({
    required this.login,
    required this.logOut,
    required this.resetPassword,
    required this.setSession,
    required this.getUserData,
    required this.saveUserData,
    required this.getServiceProviderProfilesByAuthUser,
    required this.createAccessLog,
    required this.getActiveCompanyId,
  });

  final LoginUseCase login;
  final LogOutUseCase logOut;
  final ResetPasswordUseCase resetPassword;
  final SetSessionUseCase setSession;
  final GetUserDataUseCase getUserData;
  final SaveUserDataUseCase saveUserData;
  final GetServiceProviderProfilesByAuthUserUseCase getServiceProviderProfilesByAuthUser;
  final CreateAccessLogUseCase createAccessLog;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
}
