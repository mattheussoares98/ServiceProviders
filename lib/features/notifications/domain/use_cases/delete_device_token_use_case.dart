import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/repositories/notifications_repository.dart';

@LazySingleton()
class DeleteDeviceTokenUseCase implements UseCase<bool, String> {
  const DeleteDeviceTokenUseCase({
    required NotificationsRepository repository,
  }) : _repository = repository;

  final NotificationsRepository _repository;

  @override
  FutureBool call(String deviceToken) =>
      _repository.deleteDeviceToken(deviceToken);
}
