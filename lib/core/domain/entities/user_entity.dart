import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.isActive,
  });

  const UserEntity.empty()
    : id = '',
      firstName = '',
      lastName = '',
      username = '',
      email = '',
      isActive = false;
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final bool isActive;

  UserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    bool? isActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
    'is_active': isActive,
  };

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    username,
    email,
    isActive,
  ];
}
