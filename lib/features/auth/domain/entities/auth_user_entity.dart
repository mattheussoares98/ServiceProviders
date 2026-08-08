import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, email, name, createdAt, updatedAt];
}
