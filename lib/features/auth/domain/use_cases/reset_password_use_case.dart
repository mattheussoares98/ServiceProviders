import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton()
class ResetPasswordUseCase implements UseCase<void, String> {
  const ResetPasswordUseCase({required AuthRepository repository})
    : _repository = repository;
  final AuthRepository _repository;

  @override
  FutureVoid call(String request) => _repository.resetPassword(request);
}
