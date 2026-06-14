import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/configurations/domain/entities/configurations_entity.dart';

abstract interface class ConfigurationsRepository {
  FutureData<ConfigurationsEntity> getConfigurations();
  FutureBool savePushNotifications(bool enabled);
}
