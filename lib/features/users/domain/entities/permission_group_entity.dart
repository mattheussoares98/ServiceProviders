import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';

class PermissionGroupEntity extends Equatable {
  const PermissionGroupEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.permissions,
    required this.workOrders,
    required this.isDefault,
    required this.createdAt,
    this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final Map<ResourceType, Set<PermissionAction>> permissions;
  final WorkOrdersPermissionEntity workOrders;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    permissions,
    workOrders,
    isDefault,
    createdAt,
    deletedAt,
  ];

  PermissionGroupEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    Map<ResourceType, Set<PermissionAction>>? permissions,
    WorkOrdersPermissionEntity? workOrders,
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
      workOrders: workOrders ?? this.workOrders,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
