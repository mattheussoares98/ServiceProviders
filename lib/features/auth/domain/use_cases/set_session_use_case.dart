import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';

@LazySingleton()
class SetSessionUseCase {
  SetSessionUseCase(this._sessionRepository);
  final SessionRepository _sessionRepository;

  void call(UserDataEntity userData) =>
      _sessionRepository.setUserData = userData;
}
