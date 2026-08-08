import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

@LazySingleton()
class WatchAuthUserUseCase {
  const WatchAuthUserUseCase({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  Stream<String?> call() => _sessionRepository.authUserIdStream;
}
