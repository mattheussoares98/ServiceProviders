import 'package:equatable/equatable.dart';

class UserInvitationEntity extends Equatable {
  const UserInvitationEntity({
    required this.id,
    required this.email,
    required this.invitedAt,
    required this.companyId,
    required this.permissionGroupId,
    required this.name,
  });

  final String id;
  final String email;
  final DateTime invitedAt;
  final String companyId;
  final String permissionGroupId;
  final String name;

  UserInvitationEntity copyWith({
    String? id,
    String? email,
    DateTime? invitedAt,
    String? companyId,
    String? permissionGroupId,
    String? name,
  }) {
    return UserInvitationEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      invitedAt: invitedAt ?? this.invitedAt,
      companyId: companyId ?? this.companyId,
      permissionGroupId: permissionGroupId ?? this.permissionGroupId,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        invitedAt,
        companyId,
        permissionGroupId,
        name,
      ];
}
