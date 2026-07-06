import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/sign_up_use_case.dart';

@LazySingleton()
class SignUpCubitUseCases {
  const SignUpCubitUseCases({required this.signUp});

  final SignUpUseCase signUp;
}
