import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';

class UserInvitationModel extends UserInvitationEntity
    implements DataConvertible<UserInvitationEntity> {
  const UserInvitationModel({
    required super.id,
    required super.email,
    required super.invitedAt,
    required super.companyId,
    required super.permissionGroupId,
    required super.name,
    super.confirmationSentAt,
  });
  factory UserInvitationModel.fromEntity(UserInvitationEntity entity) =>
      UserInvitationModel(
        id: entity.id,
        email: entity.email,
        invitedAt: entity.invitedAt,
        companyId: entity.companyId,
        permissionGroupId: entity.permissionGroupId,
        name: entity.name,
        confirmationSentAt: entity.confirmationSentAt,
      );

  factory UserInvitationModel.fromJson(MapDynamic json) {
    return UserInvitationModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      invitedAt: (json['invited_at'] as String?).toUtcDateTime() ??
          DateTime.now().toUtc(),
      companyId: json['company_id'] as String? ?? '',
      permissionGroupId: json['permission_group_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      confirmationSentAt:
          (json['confirmation_sent_at'] as String?).toUtcDateTime(),
    );
  }

  @override
  MapDynamic toJson() => {
    'id': id,
    'email': email,
    'invited_at': invitedAt.toIsoUtcString(),
    'company_id': companyId,
    'permission_group_id': permissionGroupId,
    'name': name,
    'confirmation_sent_at': confirmationSentAt?.toIsoUtcString(),
  };

  @override
  UserInvitationEntity toEntity() => UserInvitationEntity(
    id: id,
    email: email,
    invitedAt: invitedAt,
    companyId: companyId,
    permissionGroupId: permissionGroupId,
    name: name,
    confirmationSentAt: confirmationSentAt,
  );
}
