import 'package:equatable/equatable.dart';

class SignUpEntity extends Equatable {
  const SignUpEntity({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  SignUpEntity copyWith({String? name, String? email, String? password}) =>
      SignUpEntity(
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
      );

  @override
  List<Object?> get props => [name, email, password];
}
