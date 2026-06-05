import 'package:equatable/equatable.dart';

class AuthenticationEntity extends Equatable {
  const AuthenticationEntity({required this.email, required this.password});
  final String email;
  final String password;

  AuthenticationEntity copyWith({String? username, String? password}) =>
      AuthenticationEntity(
        email: username ?? email,
        password: password ?? this.password,
      );

  @override
  List<Object?> get props => [email, password];
}
