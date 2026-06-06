import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/domain/entities/verify_token_entity.dart';

class VerifyTokenRequestModel extends VerifyTokenEntity
    implements DataConvertible<VerifyTokenEntity> {
  const VerifyTokenRequestModel({
    required super.token,
    required super.userId,
  });

  factory VerifyTokenRequestModel.fromEntity(VerifyTokenEntity entity) =>
      VerifyTokenRequestModel(
        token: entity.token,
        userId: entity.userId,
      );

  factory VerifyTokenRequestModel.fromJson(Map<String, dynamic> json) =>
      VerifyTokenRequestModel(
        token: json['token'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
      );

  @override
  MapDynamic toJson() => {'token': token, 'user_id': userId};

  @override
  VerifyTokenEntity toEntity() => VerifyTokenEntity(token: token, userId: userId);
}
