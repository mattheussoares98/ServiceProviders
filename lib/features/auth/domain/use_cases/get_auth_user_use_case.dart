import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/auth_user_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

@LazySingleton()
class GetAuthUserUseCase {
  const GetAuthUserUseCase({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  AuthUserEntity? call() => _sessionRepository.currentAuthUser;
}
