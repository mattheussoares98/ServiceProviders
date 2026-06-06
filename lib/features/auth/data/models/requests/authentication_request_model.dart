import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';

class AuthenticationRequestModel extends AuthenticationEntity
    implements DataConvertible<AuthenticationEntity> {
  const AuthenticationRequestModel({
    required super.email,
    required super.password,
  });

  factory AuthenticationRequestModel.fromEntity(AuthenticationEntity entity) =>
      AuthenticationRequestModel(
        email: entity.email,
        password: entity.password,
      );

  factory AuthenticationRequestModel.fromJson(Map<String, dynamic> json) =>
      AuthenticationRequestModel(
        email: json['username'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  @override
  MapDynamic toJson() => {'username': email, 'password': password};

  @override
  AuthenticationEntity toEntity() => AuthenticationEntity(email: email, password: password);
}
