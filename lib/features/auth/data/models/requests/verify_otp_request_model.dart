import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/verify_otp_request_entity.dart';

class VerifyOtpRequestModel extends VerifyOtpRequestEntity
    implements DataConvertible<VerifyOtpRequestEntity> {
  const VerifyOtpRequestModel({
    required super.tokenHash,
    super.type,
  });

  factory VerifyOtpRequestModel.fromEntity(VerifyOtpRequestEntity entity) =>
      VerifyOtpRequestModel(
        tokenHash: entity.tokenHash,
        type: entity.type,
      );

  factory VerifyOtpRequestModel.fromJson(MapDynamic json) =>
      VerifyOtpRequestModel(
        tokenHash: json['token_hash'] as String? ?? '',
        type: json['type'] as String? ?? 'invite',
      );

  @override
  MapDynamic toJson() => {
    'token_hash': tokenHash,
    'type': type,
  };

  @override
  VerifyOtpRequestEntity toEntity() => VerifyOtpRequestEntity(
    tokenHash: tokenHash,
    type: type,
  );
}
