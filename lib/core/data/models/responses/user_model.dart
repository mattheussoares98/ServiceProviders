import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable implements DataConvertible<User> {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      username: user.username,
      email: user.email,
      isActive: user.isActive,
    );
  }
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final bool isActive;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
    'is_active': isActive,
  };

  @override
  User toEntity() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      isActive: isActive,
    );
  }

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
