import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/repositories/notifications_repository.dart';

final class RegisterDeviceTokenParams extends Equatable {
  const RegisterDeviceTokenParams({
    required this.deviceToken,
    required this.platform,
  });

  final String deviceToken;
  final String platform;

  @override
  List<Object?> get props => [deviceToken, platform];
}

@LazySingleton()
class RegisterDeviceTokenUseCase
    implements UseCase<bool, RegisterDeviceTokenParams> {
  const RegisterDeviceTokenUseCase({
    required NotificationsRepository repository,
  }) : _repository = repository;

  final NotificationsRepository _repository;

  @override
  FutureBool call(RegisterDeviceTokenParams params) =>
      _repository.registerDeviceToken(
        deviceToken: params.deviceToken,
        platform: params.platform,
      );
}
