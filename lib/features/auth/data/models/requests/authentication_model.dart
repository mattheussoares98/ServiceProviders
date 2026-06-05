import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';

class AuthenticationModel {
  const AuthenticationModel({required this.username, required this.password});

  factory AuthenticationModel.fromEntity(AuthenticationEntity authentication) =>
      AuthenticationModel(
        username: authentication.email,
        password: authentication.password,
      );
  final String username;
  final String password;

  Map<String, String> toJson() => {'username': username, 'password': password};
}
