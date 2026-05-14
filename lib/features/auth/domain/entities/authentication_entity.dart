import 'package:equatable/equatable.dart';

class AuthenticationEntity extends Equatable {
  const AuthenticationEntity({required this.username, required this.password});
  final String username;
  final String password;

  AuthenticationEntity copyWith({String? username, String? password}) =>
      AuthenticationEntity(
        username: username ?? this.username,
        password: password ?? this.password,
      );

  @override
  List<Object?> get props => [username, password];
}
