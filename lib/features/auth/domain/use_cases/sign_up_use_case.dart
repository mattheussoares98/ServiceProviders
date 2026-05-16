import 'package:clean_architecture/core/domain/entities/user_data.dart';
import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SignUpUseCase implements UseCase<UserDataEntity, SignUpEntity> {
  SignUpUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;
  final AuthRepository _authRepository;

  @override
  FutureData<UserDataEntity> call(SignUpEntity request) =>
      _authRepository.signUp(request);
}
