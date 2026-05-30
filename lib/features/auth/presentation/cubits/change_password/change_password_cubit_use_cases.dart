import 'package:clean_architecture/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class ChangePasswordCubitUseCases {
  const ChangePasswordCubitUseCases({
    required this.changePassword,
  });

  final ChangePasswordUseCase changePassword;
}
