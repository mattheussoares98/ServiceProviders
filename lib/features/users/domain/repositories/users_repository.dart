import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';

abstract interface class UsersRepository {
  // User Profiles
  FutureList<UserProfileEntity> getUserProfiles(String companyId);
  FutureData<UserProfileEntity> getUserProfileById(String id);
  FutureBool updateUserProfile(UserProfileEntity userProfile);
  FutureBool deleteUserProfile(String id);
  FutureVoid inviteUser({
    required String email,
    required String companyId,
    required String groupId,
  });
  FutureList<UserInvitationEntity> getPendingInvitations(String companyId);
  FutureBool revokeInvitation(String id);
  FutureVoid resendInvitation(UserInvitationEntity invitation);

  // Permission Groups
  FutureList<PermissionGroupEntity> getPermissionGroups(String companyId);
  FutureBool createPermissionGroup(PermissionGroupEntity group);
  FutureBool updatePermissionGroup(PermissionGroupEntity group);
  FutureBool deletePermissionGroup(String id);
}
