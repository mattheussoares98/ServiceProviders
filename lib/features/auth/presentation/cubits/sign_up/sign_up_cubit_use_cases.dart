import 'package:clean_architecture/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SignUpCubitUseCases {
  const SignUpCubitUseCases({
    required this.signUp,
    required this.setSession,
    required this.saveUserData,
  });

  final SignUpUseCase signUp;
  final SetSessionUseCase setSession;
  final SaveUserDataUseCase saveUserData;
}
