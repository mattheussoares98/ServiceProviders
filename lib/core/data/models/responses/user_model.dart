import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserModel extends Equatable implements DataConvertible<UserEntity> {
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
      id: json['id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  factory UserModel.fromSupabase(sb.User user) {
    return UserModel(
      id: user.id,
      firstName: user.userMetadata?['first_name'] as String? ?? '',
      lastName: user.userMetadata?['last_name'] as String? ?? '',
      username: user.userMetadata?['username'] as String? ?? '',
      email: user.email ?? '',
      isActive: true,
    );
  }

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      username: user.username,
      email: user.email,
      isActive: user.isActive,
    );
  }
  final String id;
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
  UserEntity toEntity() {
    return UserEntity(
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
