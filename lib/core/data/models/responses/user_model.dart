import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserModel extends Equatable implements DataConvertible<UserEntity> {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  factory UserModel.fromSupabase(sb.User user) {
    return UserModel(
      id: user.id,
      name: user.userMetadata?['name'] as String? ?? '',
      email: user.email ?? '',
      isActive: true,
    );
  }

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      isActive: user.isActive,
    );
  }
  @override
  List<Object?> get props => [id, name, email, isActive];
  final String id;
  final String name;
  final String email;
  final bool isActive;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'is_active': isActive,
  };

  @override
  UserEntity toEntity() {
    return UserEntity(id: id, name: name, email: email, isActive: isActive);
  }
}
