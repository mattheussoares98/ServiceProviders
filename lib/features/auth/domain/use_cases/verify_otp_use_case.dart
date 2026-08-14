import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/verify_otp_request_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton()
class VerifyOtpUseCase
    implements UseCase<UserDataEntity, VerifyOtpRequestEntity> {
  const VerifyOtpUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  FutureData<UserDataEntity> call(VerifyOtpRequestEntity request) =>
      _authRepository.verifyOtp(request);
}
