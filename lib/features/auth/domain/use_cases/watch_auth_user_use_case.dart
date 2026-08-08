import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton()
class WatchAuthUserUseCase {
  const WatchAuthUserUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Stream<String?> call() => _authRepository.authUserIdStream;
}
