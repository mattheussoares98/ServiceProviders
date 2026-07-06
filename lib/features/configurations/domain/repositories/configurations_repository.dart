import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';

abstract interface class ConfigurationsRepository {
  FutureData<ConfigurationsEntity> getConfigurations();
  FutureBool savePushNotifications(bool enabled);
}
