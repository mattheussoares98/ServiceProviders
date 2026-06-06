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
  final List<Permission> permissions;
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
}
