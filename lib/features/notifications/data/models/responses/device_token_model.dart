import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/entities/device_token_entity.dart';

class DeviceTokenModel extends DeviceTokenEntity
    implements DataConvertible<DeviceTokenEntity> {
  const DeviceTokenModel({
    required super.id,
    required super.userId,
    required super.deviceToken,
    required super.platform,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DeviceTokenModel.fromEntity(DeviceTokenEntity entity) =>
      DeviceTokenModel(
        id: entity.id,
        userId: entity.userId,
        deviceToken: entity.deviceToken,
        platform: entity.platform,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  factory DeviceTokenModel.fromJson(MapDynamic json) => DeviceTokenModel(
    id: json['id'] as String? ?? '',
    userId: json['user_id'] as String? ?? '',
    deviceToken: json['device_token'] as String? ?? '',
    platform: json['platform'] as String? ?? '',
    createdAt:
        (json['created_at'] as String?).toUtcDateTime() ?? DateTime.now(),
    updatedAt:
        (json['updated_at'] as String?).toUtcDateTime() ?? DateTime.now(),
  );

  @override
  MapDynamic toJson() => {
    'id': id,
    'user_id': userId,
    'device_token': deviceToken,
    'platform': platform,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
  };

  @override
  DeviceTokenEntity toEntity() => DeviceTokenEntity(
    id: id,
    userId: userId,
    deviceToken: deviceToken,
    platform: platform,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
