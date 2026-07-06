import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton()
class GetUserDataUseCase implements UseCaseNoParameter<UserDataEntity> {
  GetUserDataUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;
  final AuthRepository _authRepository;

  @override
  FutureData<UserDataEntity> call() => _authRepository.getUserData();
}
