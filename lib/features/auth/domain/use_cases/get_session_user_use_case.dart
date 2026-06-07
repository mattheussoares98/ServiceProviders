import 'package:clean_architecture/core/domain/entities/user_entity.dart';
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetSessionUserUseCase {
  const GetSessionUserUseCase({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository;

  final SessionRepository _sessionRepository;

  UserEntity call() => _sessionRepository.userData.user;
}
