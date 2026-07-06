import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

@LazySingleton()
class WatchSessionUseCase {
  const WatchSessionUseCase({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  Stream<UserDataEntity> call() => _sessionRepository.sessionStream;
}
