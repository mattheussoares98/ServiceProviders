import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_action.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/create_access_log_request_entity.dart';

class CreateAccessLogRequestModel extends CreateAccessLogRequestEntity
    implements DataConvertible<CreateAccessLogRequestEntity> {
  const CreateAccessLogRequestModel({
    required super.companyId,
    required super.userId,
    required super.action,
    super.ipAddress,
    super.deviceInfo,
  });

  factory CreateAccessLogRequestModel.fromEntity(
    CreateAccessLogRequestEntity entity,
  ) => CreateAccessLogRequestModel(
    companyId: entity.companyId,
    userId: entity.userId,
    action: entity.action,
    ipAddress: entity.ipAddress,
    deviceInfo: entity.deviceInfo,
  );

  factory CreateAccessLogRequestModel.fromJson(MapDynamic json) =>
      CreateAccessLogRequestModel(
        companyId: json['company_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        action:
            AccessLogAction.fromCode(json['action'] as String?) ??
            AccessLogAction.login,
        ipAddress: json['ip_address'] as String?,
        deviceInfo: json['device_info'] as String?,
      );

  @override
  MapDynamic toJson() => {
    'company_id': companyId,
    'user_id': userId,
    'action': action.code,
    if (ipAddress != null) 'ip_address': ipAddress,
    if (deviceInfo != null) 'device_info': deviceInfo,
  };

  @override
  CreateAccessLogRequestEntity toEntity() => CreateAccessLogRequestEntity(
    companyId: companyId,
    userId: userId,
    action: action,
    ipAddress: ipAddress,
    deviceInfo: deviceInfo,
  );
}
