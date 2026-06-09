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

  UserProfileEntity.empty()
    : id = '',
      companyId = '',
      name = '',
      email = '',
      phone = null,
      permissionGroupId = null,
      avatarUrl = null,
      isActive = false,
      createdAt = DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt = DateTime.fromMillisecondsSinceEpoch(0),
      deletedAt = null;

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
    bool? annulPhone,
    bool? annulPermissionGroupId,
    bool? annulAvatarUrl,
    bool? annulDeletedAt,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: annulPhone == true ? null : phone ?? this.phone,
      permissionGroupId: annulPermissionGroupId == true
          ? null
          : permissionGroupId ?? this.permissionGroupId,
      avatarUrl: annulAvatarUrl == true ? null : avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
