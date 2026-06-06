import 'package:equatable/equatable.dart';

final class UserProfileEntity extends Equatable {
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
}
