import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/create_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/delete_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/delete_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_pending_invitations_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_permission_groups_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_users_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/resend_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/revoke_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_profile_use_case.dart';

@LazySingleton()
class UsersCubitUseCases {
  const UsersCubitUseCases({
    required this.getSessionUser,
    required this.getActiveCompanyId,
    required this.getUsers,
    required this.getUserProfileById,
    required this.updateUserProfile,
    required this.deleteUserProfile,
    required this.getPermissionGroups,
    required this.createPermissionGroup,
    required this.updatePermissionGroup,
    required this.deletePermissionGroup,
    required this.getPendingInvitations,
    required this.revokeInvitation,
    required this.resendInvitation,
  });

  final GetSessionUserUseCase getSessionUser;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetUsersUseCase getUsers;
  final GetUserProfileByIdUseCase getUserProfileById;
  final UpdateUserProfileUseCase updateUserProfile;
  final DeleteUserProfileUseCase deleteUserProfile;
  final GetPermissionGroupsUseCase getPermissionGroups;
  final CreatePermissionGroupUseCase createPermissionGroup;
  final UpdatePermissionGroupUseCase updatePermissionGroup;
  final DeletePermissionGroupUseCase deletePermissionGroup;
  final GetPendingInvitationsUseCase getPendingInvitations;
  final RevokeInvitationUseCase revokeInvitation;
  final ResendInvitationUseCase resendInvitation;
}
