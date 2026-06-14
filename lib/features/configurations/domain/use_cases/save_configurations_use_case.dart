import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/configurations/domain/repositories/configurations_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SaveConfigurationsUseCase implements UseCase<bool, bool> {
  SaveConfigurationsUseCase({
    required ConfigurationsRepository configurationsRepository,
  }) : _configurationsRepository = configurationsRepository;

  final ConfigurationsRepository _configurationsRepository;

  @override
  FutureBool call(bool request) =>
      _configurationsRepository.savePushNotifications(request);
}
