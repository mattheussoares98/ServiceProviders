import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton()
class CheckAuthenticationUseCase
    implements UseCaseSynchronousNoParameter<bool> {
  CheckAuthenticationUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;
  final AuthRepository _authRepository;

  @override
  bool call() => _authRepository.checkAuth();
}
