import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton()
class SaveUserDataUseCase {
  SaveUserDataUseCase(this.authRepository);
  final AuthRepository authRepository;

  FutureBool call(UserDataEntity userData) =>
      authRepository.saveUserData(userData);
}
