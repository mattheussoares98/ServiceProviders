import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SaveUserDataUseCase {
  SaveUserDataUseCase(this.authRepository);
  final AuthRepository authRepository;

  FutureBool call(UserDataEntity userData) =>
      authRepository.saveUserData(userData);
}
