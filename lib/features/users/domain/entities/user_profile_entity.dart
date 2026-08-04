import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';

class UserProfileEntity extends Equatable {
  const UserProfileEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.email,
    required this.phone,
    required this.permissionGroupId,
    required this.avatarUrl,
    required this.isActive,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    this.permissions = const {},
    this.workOrdersPermissionOverrides =
        const UserWorkOrdersPermissionOverrideEntity.empty(),
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
      isAdmin = false,
      createdAt = DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt = DateTime.fromMillisecondsSinceEpoch(0),
      deletedAt = null,
      permissions = const {},
      workOrdersPermissionOverrides =
          const UserWorkOrdersPermissionOverrideEntity.empty();

  final String id;
  final String companyId;
  final String name;
  final String email;
  final String? phone;
  final String? permissionGroupId;
  final String? avatarUrl;
  final bool isActive;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Map<ResourceType, Map<PermissionAction, bool?>> permissions;
  final UserWorkOrdersPermissionOverrideEntity workOrdersPermissionOverrides;

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
    isAdmin,
    createdAt,
    updatedAt,
    deletedAt,
    permissions,
    workOrdersPermissionOverrides,
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
    bool? isAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    Map<ResourceType, Map<PermissionAction, bool?>>? permissions,
    UserWorkOrdersPermissionOverrideEntity? workOrders,
    bool? annulPhone,
    bool? annulPermissionGroupId,
    bool? annulAvatarUrl,
    bool? annulDeletedAt,
    bool? annulId,
    bool? annulCompanyId,
  }) {
    return UserProfileEntity(
      id: annulId == true ? '' : id ?? this.id,
      companyId: annulCompanyId == true ? '' : companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: annulPhone == true ? null : phone ?? this.phone,
      permissionGroupId: annulPermissionGroupId == true
          ? null
          : permissionGroupId ?? this.permissionGroupId,
      avatarUrl: annulAvatarUrl == true ? null : avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
      permissions: permissions ?? this.permissions,
      workOrdersPermissionOverrides:
          workOrders ?? workOrdersPermissionOverrides,
    );
  }
}
