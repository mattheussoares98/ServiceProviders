import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_action.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';

class AccessLogModel extends AccessLogEntity
    implements DataConvertible<AccessLogEntity> {
  const AccessLogModel({
    required super.id,
    required super.companyId,
    required super.userId,
    super.userName,
    super.userEmail,
    required super.action,
    super.ipAddress,
    super.deviceInfo,
    required super.createdAt,
  });

  factory AccessLogModel.fromEntity(AccessLogEntity entity) => AccessLogModel(
    id: entity.id,
    companyId: entity.companyId,
    userId: entity.userId,
    userName: entity.userName,
    userEmail: entity.userEmail,
    action: entity.action,
    ipAddress: entity.ipAddress,
    deviceInfo: entity.deviceInfo,
    createdAt: entity.createdAt,
  );

  factory AccessLogModel.fromJson(MapDynamic json) {
    final userProfile = json['user_profiles'] as MapDynamic?;

    return AccessLogModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName:
          userProfile?['name'] as String? ?? json['user_name'] as String?,
      userEmail:
          userProfile?['email'] as String? ?? json['user_email'] as String?,
      action:
          AccessLogAction.fromCode(json['action'] as String?) ??
          AccessLogAction.login,
      ipAddress: json['ip_address'] as String?,
      deviceInfo: json['device_info'] as String?,
      createdAt:
          (json['created_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'user_id': userId,
    'action': action.code,
    if (ipAddress != null) 'ip_address': ipAddress,
    if (deviceInfo != null) 'device_info': deviceInfo,
    'created_at': createdAt.toIsoUtcString(),
  };

  @override
  AccessLogEntity toEntity() => AccessLogEntity(
    id: id,
    companyId: companyId,
    userId: userId,
    userName: userName,
    userEmail: userEmail,
    action: action,
    ipAddress: ipAddress,
    deviceInfo: deviceInfo,
    createdAt: createdAt,
  );
}
