import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';

class ConfigurationsResponseModel extends ConfigurationsEntity
    implements DataConvertible<ConfigurationsEntity> {
  const ConfigurationsResponseModel({
    required super.pushNotificationsEnabled,
    required super.themeMode,
    super.systemNotificationsEnabled = true,
  });

  factory ConfigurationsResponseModel.fromEntity(ConfigurationsEntity entity) =>
      ConfigurationsResponseModel(
        pushNotificationsEnabled: entity.pushNotificationsEnabled,
        themeMode: entity.themeMode,
        systemNotificationsEnabled: entity.systemNotificationsEnabled,
      );

  factory ConfigurationsResponseModel.fromJson(MapDynamic json) =>
      ConfigurationsResponseModel(
        pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
        themeMode: json['theme_mode'] as String? ?? 'system',
      );

  @override
  MapDynamic toJson() => {
        'push_notifications_enabled': pushNotificationsEnabled,
        'theme_mode': themeMode,
      };

  @override
  ConfigurationsEntity toEntity() => ConfigurationsEntity(
        pushNotificationsEnabled: pushNotificationsEnabled,
        themeMode: themeMode,
        systemNotificationsEnabled: systemNotificationsEnabled,
      );
}
