import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';

class SignUpRequestModel extends SignUpEntity
    implements DataConvertible<SignUpEntity> {
  const SignUpRequestModel({
    required super.name,
    required super.email,
    required super.password,
  });

  factory SignUpRequestModel.fromEntity(SignUpEntity entity) =>
      SignUpRequestModel(
        name: entity.name,
        email: entity.email,
        password: entity.password,
      );

  factory SignUpRequestModel.fromJson(Map<String, dynamic> json) =>
      SignUpRequestModel(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  @override
  MapDynamic toJson() => {'name': name, 'email': email, 'password': password};

  @override
  SignUpEntity toEntity() => SignUpEntity(name: name, email: email, password: password);
}
