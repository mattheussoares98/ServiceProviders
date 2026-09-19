import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/create_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/delete_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/delete_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_pending_invitations_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_permission_groups_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_users_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/has_permission_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/resend_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/revoke_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/watch_user_profiles_realtime_use_case.dart';

class MockGetUsersUseCase extends Mock implements GetUsersUseCase {}

class MockGetUserProfileByIdUseCase extends Mock
    implements GetUserProfileByIdUseCase {}

class MockUpdateUserProfileUseCase extends Mock
    implements UpdateUserProfileUseCase {}

class MockDeleteUserProfileUseCase extends Mock
    implements DeleteUserProfileUseCase {}

class MockGetPermissionGroupsUseCase extends Mock
    implements GetPermissionGroupsUseCase {}

class MockCreatePermissionGroupUseCase extends Mock
    implements CreatePermissionGroupUseCase {}

class MockUpdatePermissionGroupUseCase extends Mock
    implements UpdatePermissionGroupUseCase {}

class MockDeletePermissionGroupUseCase extends Mock
    implements DeletePermissionGroupUseCase {}

class MockGetPendingInvitationsUseCase extends Mock
    implements GetPendingInvitationsUseCase {}

class MockRevokeInvitationUseCase extends Mock
    implements RevokeInvitationUseCase {}

class MockResendInvitationUseCase extends Mock
    implements ResendInvitationUseCase {}

class MockHasPermissionUseCase extends Mock implements HasPermissionUseCase {}

class MockWatchUserProfilesRealtimeUseCase extends Mock
    implements WatchUserProfilesRealtimeUseCase {}
