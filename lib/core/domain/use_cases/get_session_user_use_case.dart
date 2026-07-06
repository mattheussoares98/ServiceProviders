import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';

@LazySingleton()
class GetSessionUserUseCase {
  const GetSessionUserUseCase({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  UserProfileEntity call() => _sessionRepository.userData.user;
}
