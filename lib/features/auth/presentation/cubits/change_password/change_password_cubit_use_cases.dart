import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/change_password_use_case.dart';

@LazySingleton()
class ChangePasswordCubitUseCases {
  const ChangePasswordCubitUseCases({required this.changePassword});

  final ChangePasswordUseCase changePassword;
}
