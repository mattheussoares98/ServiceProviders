import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_invitation_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/domain/use_cases/create_permission_group_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/delete_permission_group_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/delete_user_profile_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_pending_invitations_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_permission_groups_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_users_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/revoke_invitation_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/update_permission_group_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit_use_cases.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetUsersUseCase mockGetUsers;
  late MockGetUserProfileByIdUseCase mockGetUserProfileById;
  late MockUpdateUserProfileUseCase mockUpdateUserProfile;
  late MockDeleteUserProfileUseCase mockDeleteUserProfile;
  late MockGetPermissionGroupsUseCase mockGetPermissionGroups;
  late MockCreatePermissionGroupUseCase mockCreatePermissionGroup;
  late MockUpdatePermissionGroupUseCase mockUpdatePermissionGroup;
  late MockDeletePermissionGroupUseCase mockDeletePermissionGroup;
  late MockGetPendingInvitationsUseCase mockGetPendingInvitations;
  late MockRevokeInvitationUseCase mockRevokeInvitation;
  late MockNavigationClient mockNavigationClient;

  late UsersCubit cubit;
  late UserProfileEntity tSessionUser;
  late UserProfileEntity tUserProfile;
  late PermissionGroupEntity tPermissionGroup;
  late UserInvitationEntity tUserInvitation;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeUserProfileEntity());
    registerFallbackValue(EntityFactory.makePermissionGroupEntity());
    registerFallbackValue(EntityFactory.makeUserInvitationEntity());
  });

  setUp(() {
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetUsers = MockGetUsersUseCase();
    mockGetUserProfileById = MockGetUserProfileByIdUseCase();
    mockUpdateUserProfile = MockUpdateUserProfileUseCase();
    mockDeleteUserProfile = MockDeleteUserProfileUseCase();
    mockGetPermissionGroups = MockGetPermissionGroupsUseCase();
    mockCreatePermissionGroup = MockCreatePermissionGroupUseCase();
    mockUpdatePermissionGroup = MockUpdatePermissionGroupUseCase();
    mockDeletePermissionGroup = MockDeletePermissionGroupUseCase();
    mockGetPendingInvitations = MockGetPendingInvitationsUseCase();
    mockRevokeInvitation = MockRevokeInvitationUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tSessionUser = EntityFactory.makeUserProfileEntity();
    tUserProfile = EntityFactory.makeUserProfileEntity();
    tPermissionGroup = EntityFactory.makePermissionGroupEntity();
    tUserInvitation = EntityFactory.makeUserInvitationEntity();

    when(() => mockGetSessionUser.call()).thenReturn(tSessionUser);

    final useCases = UsersCubitUseCases(
      getSessionUser: mockGetSessionUser,
      getUsers: mockGetUsers,
      getUserProfileById: mockGetUserProfileById,
      updateUserProfile: mockUpdateUserProfile,
      deleteUserProfile: mockDeleteUserProfile,
      getPermissionGroups: mockGetPermissionGroups,
      createPermissionGroup: mockCreatePermissionGroup,
      updatePermissionGroup: mockUpdatePermissionGroup,
      deletePermissionGroup: mockDeletePermissionGroup,
      getPendingInvitations: mockGetPendingInvitations,
      revokeInvitation: mockRevokeInvitation,
    );

    cubit = UsersCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('UsersCubit Tests', () {
    group('loadUsers', () {
      blocTest<UsersCubit, UsersState>(
        'should emit loading and loaded when users load successfully',
        build: () {
          final tUsers = EntityFactory.makeUserProfileEntityList();
          when(
            () => mockGetUsers.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tUsers));
          return cubit;
        },
        act: (cubit) => cubit.loadUsers(),
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.users, 'users', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
        verify: (_) {
          verify(() => mockGetUsers.call(tSessionUser.companyId)).called(1);
        },
      );

      blocTest<UsersCubit, UsersState>(
        'should emit error status when companyId is empty',
        build: () {
          when(
            () => mockGetSessionUser.call(),
          ).thenReturn(tSessionUser.copyWith(companyId: ''));
          return cubit;
        },
        act: (cubit) => cubit.loadUsers(),
        expect: () => [
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.users, 'users', isEmpty),
        ],
      );

      blocTest<UsersCubit, UsersState>(
        'should emit error and show error toast when loading fails',
        build: () {
          when(
            () => mockGetUsers.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error message'));
          return cubit;
        },
        act: (cubit) => cubit.loadUsers(),
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Error message'),
        ],
      );
    });

    group('loadPermissionGroups', () {
      blocTest<UsersCubit, UsersState>(
        'should emit loading and loaded when permission groups load successfully',
        build: () {
          final tGroups = EntityFactory.makePermissionGroupEntityList();
          when(
            () => mockGetPermissionGroups.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tGroups));
          return cubit;
        },
        act: (cubit) => cubit.loadPermissionGroups(),
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.permissionGroups, 'permissionGroups', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
        verify: (_) {
          verify(
            () => mockGetPermissionGroups.call(tSessionUser.companyId),
          ).called(1);
        },
      );

      blocTest<UsersCubit, UsersState>(
        'should emit error and show error toast when loading permission groups fails',
        build: () {
          when(
            () => mockGetPermissionGroups.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Group load failed'));
          return cubit;
        },
        act: (cubit) => cubit.loadPermissionGroups(),
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Group load failed',
              ),
        ],
      );
    });

    group('loadAll', () {
      blocTest<UsersCubit, UsersState>(
        'should emit loading, load users, load permission groups, and load invitations',
        build: () {
          final tUsers = EntityFactory.makeUserProfileEntityList();
          final tGroups = EntityFactory.makePermissionGroupEntityList();
          final tInvitations = EntityFactory.makeUserInvitationEntityList();
          when(
            () => mockGetUsers.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tUsers));
          when(
            () => mockGetPermissionGroups.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tGroups));
          when(
            () => mockGetPendingInvitations.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tInvitations));
          return cubit;
        },
        act: (cubit) => cubit.loadAll(),
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.users, 'users', isNotEmpty),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having(
                (s) => s.permissionGroups,
                'permissionGroups',
                isNotEmpty,
              ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.invitations, 'invitations', isNotEmpty),
        ],
      );
    });

    group('loadInvitations', () {
      blocTest<UsersCubit, UsersState>(
        'should emit loaded status and invitations on success',
        build: () {
          when(
            () => mockGetPendingInvitations.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tUserInvitation]));
          return cubit;
        },
        act: (cubit) => cubit.loadInvitations(),
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.invitations, 'invitations', [tUserInvitation]),
        ],
      );

      blocTest<UsersCubit, UsersState>(
        'should emit loadingError status on failure',
        build: () {
          when(
            () => mockGetPendingInvitations.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error loading'));
          return cubit;
        },
        act: (cubit) => cubit.loadInvitations(),
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Error loading'),
        ],
      );
    });

    group('revokeInvitation', () {
      blocTest<UsersCubit, UsersState>(
        'should emit deleting status, call revokeInvitation and refresh invitations on success',
        seed: () => UsersState(
          users: const [],
          permissionGroups: const [],
          invitations: [tUserInvitation],
        ),
        build: () {
          when(
            () => mockRevokeInvitation.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetPendingInvitations.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.revokeInvitation(tUserInvitation.id),
        expect: () => [
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.deleting)
              .having((s) => s.deletingInvitationIds, 'deletingInvitationIds', {
                tUserInvitation.id,
              }),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.deletingInvitationIds, 'deletingInvitationIds', {
                tUserInvitation.id,
              }),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.invitations, 'invitations', isEmpty)
              .having(
                (s) => s.deletingInvitationIds,
                'deletingInvitationIds',
                isEmpty,
              ),
        ],
      );

      blocTest<UsersCubit, UsersState>(
        'should emit deletingError on failure',
        seed: () => UsersState(
          users: const [],
          permissionGroups: const [],
          invitations: [tUserInvitation],
        ),
        build: () {
          when(
            () => mockRevokeInvitation.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error revoking'));
          return cubit;
        },
        act: (cubit) => cubit.revokeInvitation(tUserInvitation.id),
        expect: () => [
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.deleting)
              .having((s) => s.deletingInvitationIds, 'deletingInvitationIds', {
                tUserInvitation.id,
              }),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.deletingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Error revoking')
              .having(
                (s) => s.deletingInvitationIds,
                'deletingInvitationIds',
                isEmpty,
              ),
        ],
      );
    });

    group('updateUserPermissions', () {
      blocTest<UsersCubit, UsersState>(
        'should emit saving, call updateUserProfile and refresh users on success',
        seed: () =>
            UsersState(users: [tUserProfile], permissionGroups: const []),
        build: () {
          when(
            () => mockUpdateUserProfile.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetUsers.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tUserProfile]));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.updateUserPermissions(
            tUserProfile.id,
            tUserProfile.permissions,
          );
          expect(result, isTrue);
        },
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.users, 'users', [tUserProfile]),
        ],
        verify: (_) {
          verify(() => mockUpdateUserProfile.call(tUserProfile)).called(1);
          verify(() => mockGetUsers.call(tSessionUser.companyId)).called(1);
        },
      );

      blocTest<UsersCubit, UsersState>(
        'should emit error and show toast when updateUserProfile fails',
        seed: () =>
            UsersState(users: [tUserProfile], permissionGroups: const []),
        build: () {
          when(
            () => mockUpdateUserProfile.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Update failed'));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.updateUserPermissions(
            tUserProfile.id,
            tUserProfile.permissions,
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Update failed'),
        ],
      );

      blocTest<UsersCubit, UsersState>(
        'should emit savingError when user is not found in state.users',
        build: () => cubit,
        act: (cubit) async {
          final result = await cubit.updateUserPermissions(
            'non-existent-id',
            const {},
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Usuário não encontrado',
              ),
        ],
      );
    });

    group('updateUserPermissionGroup', () {
      blocTest<UsersCubit, UsersState>(
        'should emit saving, call updateUserProfile and refresh users on success',
        seed: () =>
            UsersState(users: [tUserProfile], permissionGroups: const []),
        build: () {
          when(
            () => mockUpdateUserProfile.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetUsers.call(any()),
          ).thenAnswer((_) async => SuccessState(data: [tUserProfile]));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.updateUserPermissionGroup(
            tUserProfile.id,
            tPermissionGroup.id,
          );
          expect(result, isTrue);
        },
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.users, 'users', [tUserProfile]),
        ],
        verify: (_) {
          final expectedUpdatedUser = tUserProfile.copyWith(
            permissionGroupId: tPermissionGroup.id,
          );
          verify(
            () => mockUpdateUserProfile.call(expectedUpdatedUser),
          ).called(1);
          verify(() => mockGetUsers.call(tSessionUser.companyId)).called(1);
        },
      );

      blocTest<UsersCubit, UsersState>(
        'should emit error and show toast when updateUserProfile fails',
        seed: () =>
            UsersState(users: [tUserProfile], permissionGroups: const []),
        build: () {
          when(
            () => mockUpdateUserProfile.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Update failed'));
          return cubit;
        },
        act: (cubit) async {
          final result = await cubit.updateUserPermissionGroup(
            tUserProfile.id,
            tPermissionGroup.id,
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Update failed'),
        ],
      );

      blocTest<UsersCubit, UsersState>(
        'should emit savingError when user is not found in state.users',
        build: () => cubit,
        act: (cubit) async {
          final result = await cubit.updateUserPermissionGroup(
            'non-existent-id',
            tPermissionGroup.id,
          );
          expect(result, isFalse);
        },
        expect: () => [
          isA<UsersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Usuário não encontrado',
              ),
        ],
      );
    });

    group('deleteUserProfile', () {
      final tId = faker.guid.guid();

      blocTest<UsersCubit, UsersState>(
        'should emit deleting, call deleteUserProfile and refresh on success',
        build: () {
          when(
            () => mockDeleteUserProfile.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetUsers.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async =>
            expect(await cubit.deleteUserProfile(tId), isTrue),
        expect: () => [
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.deleting)
              .having((s) => s.deletingUserIds, 'deletingUserIds', {tId}),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.deletingUserIds, 'deletingUserIds', {tId})
              .having((s) => s.users, 'users', isEmpty),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.deletingUserIds, 'deletingUserIds', isEmpty)
              .having((s) => s.users, 'users', isEmpty),
        ],
      );

      blocTest<UsersCubit, UsersState>(
        'should emit error and show toast when deletion fails',
        build: () {
          when(
            () => mockDeleteUserProfile.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Delete failed'));
          return cubit;
        },
        act: (cubit) async =>
            expect(await cubit.deleteUserProfile(tId), isFalse),
        expect: () => [
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.deleting)
              .having((s) => s.deletingUserIds, 'deletingUserIds', {tId}),
          isA<UsersState>()
              .having((s) => s.status, 'status', StateStatus.deletingError)
              .having((s) => s.deletingUserIds, 'deletingUserIds', isEmpty)
              .having((s) => s.errorMessage, 'errorMessage', 'Delete failed'),
        ],
      );
    });

    group('Permission Groups Operations', () {
      group('savePermissionGroup', () {
        blocTest<UsersCubit, UsersState>(
          'should emit saving, call createPermissionGroup and refresh on success',
          build: () {
            when(
              () => mockCreatePermissionGroup.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetPermissionGroups.call(any()),
            ).thenAnswer((_) async => SuccessState(data: [tPermissionGroup]));
            return cubit;
          },
          act: (cubit) async {
            final result = await cubit.savePermissionGroup(
              tPermissionGroup,
              isUpdate: false,
            );
            expect(result, isTrue);
          },
          expect: () => [
            isA<UsersState>().having(
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<UsersState>()
                .having((s) => s.status, 'status', StateStatus.loaded)
                .having((s) => s.permissionGroups, 'permissionGroups', [
                  tPermissionGroup,
                ]),
          ],
          verify: (_) {
            verify(
              () => mockCreatePermissionGroup.call(tPermissionGroup),
            ).called(1);
            verify(
              () => mockGetPermissionGroups.call(tSessionUser.companyId),
            ).called(1);
          },
        );

        blocTest<UsersCubit, UsersState>(
          'should emit saving, call updatePermissionGroup and refresh on success',
          build: () {
            when(
              () => mockUpdatePermissionGroup.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetPermissionGroups.call(any()),
            ).thenAnswer((_) async => SuccessState(data: [tPermissionGroup]));
            return cubit;
          },
          act: (cubit) async {
            final result = await cubit.savePermissionGroup(
              tPermissionGroup,
              isUpdate: true,
            );
            expect(result, isTrue);
          },
          expect: () => [
            isA<UsersState>().having(
              (s) => s.status,
              'status',
              StateStatus.saving,
            ),
            isA<UsersState>()
                .having((s) => s.status, 'status', StateStatus.loaded)
                .having((s) => s.permissionGroups, 'permissionGroups', [
                  tPermissionGroup,
                ]),
          ],
          verify: (_) {
            verify(
              () => mockUpdatePermissionGroup.call(tPermissionGroup),
            ).called(1);
          },
        );
      });

      group('deletePermissionGroup', () {
        final tId = faker.guid.guid();

        blocTest<UsersCubit, UsersState>(
          'should emit deleting, call deletePermissionGroup and refresh on success',
          build: () {
            when(
              () => mockDeletePermissionGroup.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));
            when(
              () => mockGetPermissionGroups.call(any()),
            ).thenAnswer((_) async => const SuccessState(data: []));
            return cubit;
          },
          act: (cubit) => cubit.deletePermissionGroup(tId),
          expect: () => [
            isA<UsersState>()
                .having((s) => s.status, 'status', StateStatus.deleting)
                .having((s) => s.deletingGroupIds, 'deletingGroupIds', {tId}),
            isA<UsersState>()
                .having((s) => s.status, 'status', StateStatus.loaded)
                .having((s) => s.deletingGroupIds, 'deletingGroupIds', {tId})
                .having((s) => s.permissionGroups, 'permissionGroups', isEmpty),
            isA<UsersState>()
                .having((s) => s.status, 'status', StateStatus.loaded)
                .having((s) => s.deletingGroupIds, 'deletingGroupIds', isEmpty)
                .having((s) => s.permissionGroups, 'permissionGroups', isEmpty),
          ],
        );
      });
    });

    group('hasPermission', () {
      final resource = ResourceType
          .values[faker.randomGenerator.integer(ResourceType.values.length)];
      final action =
          PermissionAction.values[faker.randomGenerator.integer(
            PermissionAction.values.length,
          )];
      test('should return true when user is admin', () {
        final adminUser = tSessionUser.copyWith(isAdmin: true);
        when(() => mockGetSessionUser.call()).thenReturn(adminUser);

        final hasPerm = cubit.hasPermission(resource, action);

        expect(hasPerm, isTrue);
      });

      test(
        'should return false when user is not admin and has no permissionGroupId',
        () {
          final regularUser = tSessionUser.copyWith(
            isAdmin: false,
            annulPermissionGroupId: true,
          );
          when(() => mockGetSessionUser.call()).thenReturn(regularUser);

          final hasPerm = cubit.hasPermission(resource, action);

          expect(hasPerm, isFalse);
        },
      );

      test(
        'should return false when user is not admin and permissionGroupId is empty',
        () {
          final regularUser = tSessionUser.copyWith(
            isAdmin: false,
            permissionGroupId: '',
          );
          when(() => mockGetSessionUser.call()).thenReturn(regularUser);

          final hasPerm = cubit.hasPermission(resource, action);

          expect(hasPerm, isFalse);
        },
      );

      test('should return false when permission group is not in state', () {
        final groupId = faker.guid.guid();
        final regularUser = tSessionUser.copyWith(
          isAdmin: false,
          permissionGroupId: groupId,
        );
        when(() => mockGetSessionUser.call()).thenReturn(regularUser);

        final hasPerm = cubit.hasPermission(resource, action);

        expect(hasPerm, isFalse);
      });

      test(
        'should return false when permission group exists but does not have the resource',
        () {
          final groupId = faker.guid.guid();
          final regularUser = tSessionUser.copyWith(
            isAdmin: false,
            permissionGroupId: groupId,
          );
          when(() => mockGetSessionUser.call()).thenReturn(regularUser);

          final group = tPermissionGroup.copyWith(
            id: groupId,
            permissions: {
              ResourceType.attachments: {PermissionAction.read},
            },
          );

          cubit.emit(cubit.state.copyWith(permissionGroups: [group]));

          final hasPerm = cubit.hasPermission(
            ResourceType.workOrders,
            PermissionAction.read,
          );

          expect(hasPerm, isFalse);
        },
      );

      test(
        'should return false when permission group has the resource but not the action',
        () {
          final groupId = faker.guid.guid();
          final regularUser = tSessionUser.copyWith(
            isAdmin: false,
            permissionGroupId: groupId,
          );
          when(() => mockGetSessionUser.call()).thenReturn(regularUser);

          final group = tPermissionGroup.copyWith(
            id: groupId,
            permissions: {
              ResourceType.workOrders: {PermissionAction.read},
            },
          );

          cubit.emit(cubit.state.copyWith(permissionGroups: [group]));

          final hasPerm = cubit.hasPermission(
            ResourceType.workOrders,
            PermissionAction.delete,
          );

          expect(hasPerm, isFalse);
        },
      );

      test(
        'should return true when permission group has both the resource and the action',
        () {
          final groupId = faker.guid.guid();
          final regularUser = tSessionUser.copyWith(
            isAdmin: false,
            permissionGroupId: groupId,
          );
          when(() => mockGetSessionUser.call()).thenReturn(regularUser);

          final group = tPermissionGroup.copyWith(
            id: groupId,
            permissions: {
              ResourceType.workOrders: {PermissionAction.delete},
            },
          );

          cubit.emit(cubit.state.copyWith(permissionGroups: [group]));

          final hasPerm = cubit.hasPermission(
            ResourceType.workOrders,
            PermissionAction.delete,
          );

          expect(hasPerm, isTrue);
        },
      );

      test(
        'should return true when user has explicit active override, even if group does not have it',
        () {
          final groupId = faker.guid.guid();
          final regularUser = tSessionUser.copyWith(
            isAdmin: false,
            permissionGroupId: groupId,
            permissions: const {
              ResourceType.workOrders: {PermissionAction.delete: true},
            },
          );
          when(() => mockGetSessionUser.call()).thenReturn(regularUser);

          final group = tPermissionGroup.copyWith(
            id: groupId,
            permissions: {
              ResourceType.workOrders: {PermissionAction.read},
            },
          );

          cubit.emit(cubit.state.copyWith(permissionGroups: [group]));

          final hasPerm = cubit.hasPermission(
            ResourceType.workOrders,
            PermissionAction.delete,
          );

          expect(hasPerm, isTrue);
        },
      );

      test(
        'should return false when user has explicit inactive override, even if group has it',
        () {
          final groupId = faker.guid.guid();
          final regularUser = tSessionUser.copyWith(
            isAdmin: false,
            permissionGroupId: groupId,
            permissions: const {
              ResourceType.workOrders: {PermissionAction.delete: false},
            },
          );
          when(() => mockGetSessionUser.call()).thenReturn(regularUser);

          final group = tPermissionGroup.copyWith(
            id: groupId,
            permissions: {
              ResourceType.workOrders: {PermissionAction.delete},
            },
          );

          cubit.emit(cubit.state.copyWith(permissionGroups: [group]));

          final hasPerm = cubit.hasPermission(
            ResourceType.workOrders,
            PermissionAction.delete,
          );

          expect(hasPerm, isFalse);
        },
      );

      test(
        'should fallback to group permission when user has no explicit override for action',
        () {
          final groupId = faker.guid.guid();
          final regularUser = tSessionUser.copyWith(
            isAdmin: false,
            permissionGroupId: groupId,
            permissions: const {
              ResourceType.workOrders: {PermissionAction.read: true},
            },
          );
          when(() => mockGetSessionUser.call()).thenReturn(regularUser);

          final group = tPermissionGroup.copyWith(
            id: groupId,
            permissions: {
              ResourceType.workOrders: {PermissionAction.delete},
            },
          );

          cubit.emit(cubit.state.copyWith(permissionGroups: [group]));

          final hasPerm = cubit.hasPermission(
            ResourceType.workOrders,
            PermissionAction.delete,
          );

          expect(hasPerm, isTrue);
        },
      );

      test(
        'should use user profile from state.users instead of sessionUser when available',
        () {
          final regularUser = tSessionUser.copyWith(
            isAdmin: false,
            permissions: {
              ResourceType.workOrders: {PermissionAction.create: false},
            },
          );
          when(() => mockGetSessionUser.call()).thenReturn(regularUser);

          final updatedUser = regularUser.copyWith(
            permissions: {
              ResourceType.workOrders: {PermissionAction.create: true},
            },
          );

          cubit.emit(cubit.state.copyWith(users: [updatedUser]));

          final hasPerm = cubit.hasPermission(
            ResourceType.workOrders,
            PermissionAction.create,
          );

          expect(hasPerm, isTrue);
        },
      );
    });
  });
}
