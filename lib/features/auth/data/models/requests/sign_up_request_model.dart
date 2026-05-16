import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';

class SignUpRequestModel extends SignUpEntity {
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

  MapDynamic toJson() => {'name': name, 'email': email, 'password': password};
}
