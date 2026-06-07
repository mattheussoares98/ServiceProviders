import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  const UserProfileEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.email,
    this.phone,
    this.permissionGroupId,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final String email;
  final String? phone;
  final String? permissionGroupId;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        companyId,
        name,
        email,
        phone,
        permissionGroupId,
        avatarUrl,
        isActive,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  UserProfileEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    String? email,
    String? phone,
    String? permissionGroupId,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      permissionGroupId: permissionGroupId ?? this.permissionGroupId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  UserProfileEntity annulPhone() => UserProfileEntity(
        id: id,
        companyId: companyId,
        name: name,
        email: email,
        phone: null,
        permissionGroupId: permissionGroupId,
        avatarUrl: avatarUrl,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  UserProfileEntity annulPermissionGroupId() => UserProfileEntity(
        id: id,
        companyId: companyId,
        name: name,
        email: email,
        phone: phone,
        permissionGroupId: null,
        avatarUrl: avatarUrl,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  UserProfileEntity annulAvatarUrl() => UserProfileEntity(
        id: id,
        companyId: companyId,
        name: name,
        email: email,
        phone: phone,
        permissionGroupId: permissionGroupId,
        avatarUrl: null,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  UserProfileEntity annulDeletedAt() => UserProfileEntity(
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
        deletedAt: null,
      );
}
