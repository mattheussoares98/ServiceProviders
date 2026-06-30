import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/users/domain/entities/user_invitation_entity.dart';

class UserInvitationResponseModel extends UserInvitationEntity
    implements DataConvertible<UserInvitationEntity> {
  const UserInvitationResponseModel({
    required super.id,
    required super.email,
    required super.invitedAt,
    required super.companyId,
    required super.permissionGroupId,
    required super.name,
  });
  //TODO remove the response from the name
  factory UserInvitationResponseModel.fromEntity(UserInvitationEntity entity) =>
      UserInvitationResponseModel(
        id: entity.id,
        email: entity.email,
        invitedAt: entity.invitedAt,
        companyId: entity.companyId,
        permissionGroupId: entity.permissionGroupId,
        name: entity.name,
      );

  factory UserInvitationResponseModel.fromJson(MapDynamic json) {
    return UserInvitationResponseModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      invitedAt: json['invited_at'] != null
          ? DateTime.parse(json['invited_at'] as String)
          : DateTime.now(),
      companyId: json['company_id'] as String? ?? '',
      permissionGroupId: json['permission_group_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'email': email,
    'invited_at': invitedAt.toIso8601String(),
    'company_id': companyId,
    'permission_group_id': permissionGroupId,
    'name': name,
  };

  @override
  UserInvitationEntity toEntity() => UserInvitationEntity(
    id: id,
    email: email,
    invitedAt: invitedAt,
    companyId: companyId,
    permissionGroupId: permissionGroupId,
    name: name,
  );
}
