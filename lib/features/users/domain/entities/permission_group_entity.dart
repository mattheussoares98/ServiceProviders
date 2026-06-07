import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:equatable/equatable.dart';

class PermissionGroupEntity extends Equatable {
  const PermissionGroupEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.permissions,
    required this.isDefault,
    required this.createdAt,
    this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final List<ResourcePermissionEntity> permissions;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        companyId,
        name,
        permissions,
        isDefault,
        createdAt,
        deletedAt,
      ];

  PermissionGroupEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    List<ResourcePermissionEntity>? permissions,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool? annulDeletedAt,
  }) {
    return PermissionGroupEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
