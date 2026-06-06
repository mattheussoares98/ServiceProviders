import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/domain/entities/user_entity.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserModel extends UserEntity implements DataConvertible<UserEntity> {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.isActive,
  });

  factory UserModel.fromJson(MapDynamic json) {
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
  MapDynamic toJson() => {
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
