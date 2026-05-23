import 'package:clean_architecture/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SignUpCubitUseCases {
  const SignUpCubitUseCases({required this.signUp});

  final SignUpUseCase signUp;
}
