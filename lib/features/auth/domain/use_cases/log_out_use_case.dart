import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

@LazySingleton()
class LogOutUseCase {
  LogOutUseCase(this._sessionRepository);
  final SessionRepository _sessionRepository;

  Future<void> call() => _sessionRepository.logout();
}
