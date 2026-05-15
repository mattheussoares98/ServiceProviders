import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class ResetPasswordUseCase implements UseCase<void, String> {
  const ResetPasswordUseCase({required AuthRepository repository})
    : _repository = repository;
  final AuthRepository _repository;

  @override
  FutureVoid call(String request) => _repository.resetPassword(request);
}
