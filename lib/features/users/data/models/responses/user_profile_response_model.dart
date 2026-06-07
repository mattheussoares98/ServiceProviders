import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';

class UserProfileResponseModel extends UserProfileEntity
    implements DataConvertible<UserProfileEntity> {
  const UserProfileResponseModel({
    required super.id,
    required super.companyId,
    required super.name,
    required super.email,
    super.phone,
    super.permissionGroupId,
    super.avatarUrl,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory UserProfileResponseModel.fromEntity(UserProfileEntity entity) =>
      UserProfileResponseModel(
        id: entity.id,
        companyId: entity.companyId,
        name: entity.name,
        email: entity.email,
        phone: entity.phone,
        permissionGroupId: entity.permissionGroupId,
        avatarUrl: entity.avatarUrl,
        isActive: entity.isActive,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        deletedAt: entity.deletedAt,
      );

  factory UserProfileResponseModel.fromDb(UserProfile db) =>
      UserProfileResponseModel(
        id: db.id,
        companyId: db.companyId,
        name: db.name,
        email: db.email,
        phone: db.phone,
        permissionGroupId: db.permissionGroupId,
        avatarUrl: db.avatarUrl,
        isActive: db.isActive,
        createdAt: db.createdAt,
        updatedAt: db.updatedAt,
        deletedAt: db.deletedAt,
      );

  factory UserProfileResponseModel.fromJson(MapDynamic json) =>
      UserProfileResponseModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        permissionGroupId: json['permission_group_id'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
      );

  @override
  MapDynamic toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'email': email,
        'phone': phone,
        'permission_group_id': permissionGroupId,
        'avatar_url': avatarUrl,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  @override
  UserProfileEntity toEntity() => UserProfileEntity(
        id: id,
        companyId: companyId,
        name: name,
        email: email,
        phone: phone,
        permissionGroupId: permissionGroupId,
        avatarUrl: avatarUrl,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );
}
