import 'package:clean_architecture/features/auth/domain/use_cases/get_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/login_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class LoginCubitUseCases {
  const LoginCubitUseCases({
    required this.login,
    required this.logOut,
    required this.resetPassword,
    required this.setSession,
    required this.getUserData,
    required this.saveUserData,
  });

  final LoginUseCase login;
  final LogOutUseCase logOut;
  final ResetPasswordUseCase resetPassword;
  final SetSessionUseCase setSession;
  final GetUserDataUseCase getUserData;
  final SaveUserDataUseCase saveUserData;
}
