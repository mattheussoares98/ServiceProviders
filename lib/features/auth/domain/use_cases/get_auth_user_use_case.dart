import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/auth_user_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton()
class GetAuthUserUseCase {
  const GetAuthUserUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  AuthUserEntity? call() => _authRepository.currentAuthUser;
}
