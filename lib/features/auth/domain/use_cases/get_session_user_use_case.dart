import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetSessionUserUseCase {
  const GetSessionUserUseCase({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  UserProfileEntity call() => _sessionRepository.userData.user;
}
