import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockUsersCubit extends Mock implements UsersCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PermissionsCubit cubit;
  late MockUsersCubit mockUsersCubit;
  late PermissionGroupEntity tGroup;
  late UserProfileEntity tUser;
  late MockNavigationClient mockNavigationClient;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makePermissionGroupEntity());
    registerFallbackValue(EntityFactory.makeUserProfileEntity());
    registerFallbackValue(const WorkOrdersPermissionEntity.defaultTechnical());
    registerFallbackValue(const UserWorkOrdersPermissionOverrideEntity.empty());
  });

  setUp(() {
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    cubit = PermissionsCubit();
    mockUsersCubit = MockUsersCubit();
    tGroup = EntityFactory.makePermissionGroupEntity();
    tUser = EntityFactory.makeUserProfileEntity();
  });

  tearDown(GetIt.I.reset);
  group('PermissionsCubit Group Logic', () {
    test('initial state should be PermissionsState', () {
      expect(cubit.state, const PermissionsState());
    });

    blocTest<PermissionsCubit, PermissionsState>(
      'initGroup initializes permissions correctly',
      build: () => cubit,
      act: (c) => c.initGroup(tGroup),
      expect: () => [
        isA<PermissionsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.group, 'group', tGroup)
            .having((s) => s.isAdmin, 'isAdmin', false)
            .having(
              (s) =>
                  s.draftGroupPermissions.containsKey(ResourceType.workOrders),
              'has workOrders',
              false,
            ),
      ],
    );

    blocTest<PermissionsCubit, PermissionsState>(
      'toggleGroupPermission updates localGroupPermissions',
      build: () => cubit..initGroup(tGroup),
      act: (c) => c.toggleGroupPermission(
        ResourceType.assets,
        PermissionAction.create,
        true,
      ),
      expect: () => [
        isA<PermissionsState>().having(
          (s) => s.draftGroupPermissions[ResourceType.assets],
          'actions list',
          {PermissionAction.create},
        ),
      ],
    );

    blocTest<PermissionsCubit, PermissionsState>(
      'saveGroupPermissions calls UsersCubit.savePermissionGroup and emits loaded on success',
      build: () {
        when(
          () => mockUsersCubit.savePermissionGroup(any(), isUpdate: true),
        ).thenAnswer((_) async => true);
        return cubit..initGroup(tGroup);
      },
      act: (c) => c.saveGroupPermissions(mockUsersCubit),
      expect: () => [
        isA<PermissionsState>().having(
          (s) => s.status,
          'status',
          StateStatus.saving,
        ),
        isA<PermissionsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loaded,
        ),
      ],
    );

    blocTest<PermissionsCubit, PermissionsState>(
      'saveGroupPermissions emits error on failure',
      build: () {
        when(
          () => mockUsersCubit.savePermissionGroup(any(), isUpdate: true),
        ).thenAnswer((_) async => false);
        return cubit..initGroup(tGroup);
      },
      act: (c) => c.saveGroupPermissions(mockUsersCubit),
      expect: () => [
        isA<PermissionsState>().having(
          (s) => s.status,
          'status',
          StateStatus.saving,
        ),
        isA<PermissionsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loaded,
        ),
      ],
    );
    blocTest<PermissionsCubit, PermissionsState>(
      'toggleGroupWorkOrdersDeleteObservation updates state draftGroupWorkOrders',
      build: () => cubit..initGroup(tGroup),
      act: (c) => c.toggleGroupWorkOrdersDeleteObservation(true),
      expect: () => [
        isA<PermissionsState>().having(
          (s) => s.draftGroupWorkOrders.deleteObservation,
          'deleteObservation',
          true,
        ),
      ],
    );
  });

  group('PermissionsCubit User Logic', () {
    blocTest<PermissionsCubit, PermissionsState>(
      'initUser initializes overrides and selectedGroupId correctly',
      build: () => cubit,
      act: (c) => c.initUser(tUser),
      expect: () => [
        isA<PermissionsState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.user, 'user', tUser)
            .having((s) => s.isAdmin, 'isAdmin', false)
            .having(
              (s) => s.selectedGroupId,
              'selectedGroupId',
              tUser.permissionGroupId,
            ),
      ],
    );

    blocTest<PermissionsCubit, PermissionsState>(
      'changeUserGroup updates selectedGroupId, sets isAdmin to false, and retains overrides for non-admin group',
      build: () => cubit..initUser(tUser),
      act: (c) {
        final normalGroup = EntityFactory.makePermissionGroupEntity().copyWith(
          id: 'new-group-id',
          name: 'Normal Group',
        );
        when(() => mockUsersCubit.state).thenReturn(
          UsersState(users: const [], permissionGroups: [normalGroup]),
        );
        c.changeUserGroup('new-group-id', mockUsersCubit);
      },
      expect: () => [
        isA<PermissionsState>()
            .having((s) => s.selectedGroupId, 'selectedGroupId', 'new-group-id')
            .having((s) => s.isAdmin, 'isAdmin', false),
      ],
    );

    blocTest<PermissionsCubit, PermissionsState>(
      'changeUserGroup updates selectedGroupId, sets isAdmin to true, and clears overrides for admin group',
      build: () => cubit
        ..initUser(tUser)
        ..setUserPermissionOverride(
          ResourceType.attachments,
          PermissionAction.create,
          true,
        ),
      act: (c) {
        final adminGroup = EntityFactory.makePermissionGroupEntity().copyWith(
          id: 'admin-group-id',
          name: 'Administrador',
        );
        when(() => mockUsersCubit.state).thenReturn(
          UsersState(users: const [], permissionGroups: [adminGroup]),
        );
        c.changeUserGroup('admin-group-id', mockUsersCubit);
      },
      expect: () => [
        isA<PermissionsState>()
            .having(
              (s) => s.selectedGroupId,
              'selectedGroupId',
              'admin-group-id',
            )
            .having((s) => s.isAdmin, 'isAdmin', true)
            .having(
              (s) => s.draftUserPermissions,
              'draftUserPermissions',
              const <ResourceType, Map<PermissionAction, bool?>>{},
            ),
      ],
    );

    group('isGroupAdmin', () {
      test(
        'returns true when group name is "Administrador" (case-insensitive)',
        () {
          final groups = [
            EntityFactory.makePermissionGroupEntity().copyWith(
              id: 'admin-id',
              name: 'Administrador',
            ),
            EntityFactory.makePermissionGroupEntity().copyWith(
              id: 'admin-id-lowercase',
              name: 'administrador',
            ),
          ];

          expect(cubit.isGroupAdmin('admin-id', groups), isTrue);
          expect(cubit.isGroupAdmin('admin-id-lowercase', groups), isTrue);
        },
      );

      test(
        'returns false when group name is not "Administrador" or group is not found/null',
        () {
          final groups = [
            EntityFactory.makePermissionGroupEntity().copyWith(
              id: 'normal-id',
              name: 'Normal Group',
            ),
          ];

          expect(cubit.isGroupAdmin('normal-id', groups), isFalse);
          expect(cubit.isGroupAdmin('unknown-id', groups), isFalse);
          expect(cubit.isGroupAdmin(null, groups), isFalse);
        },
      );
    });

    blocTest<PermissionsCubit, PermissionsState>(
      'setUserPermissionOverride updates state overrides',
      build: () => cubit..initUser(tUser),
      act: (c) => c.setUserPermissionOverride(
        ResourceType.attachments,
        PermissionAction.create,
        true,
      ),
      expect: () => [
        isA<PermissionsState>().having(
          (s) =>
              s.draftUserPermissions[ResourceType.attachments]?[PermissionAction
                  .create],
          'override status',
          true,
        ),
      ],
    );

    blocTest<PermissionsCubit, PermissionsState>(
      'saveUserPermissions calls UsersCubit.updateUserPermissions and emits loaded on success',
      build: () {
        when(
          () => mockUsersCubit.updateUserPermissions(
            any(),
            any(),
            groupId: any(named: 'groupId'),
            workOrders: any(named: 'workOrders'),
          ),
        ).thenAnswer((_) async => true);
        return cubit..initUser(tUser);
      },
      act: (c) => c.saveUserPermissions(mockUsersCubit),
      expect: () => [
        isA<PermissionsState>().having(
          (s) => s.status,
          'status',
          StateStatus.saving,
        ),
        isA<PermissionsState>().having(
          (s) => s.status,
          'status',
          StateStatus.loaded,
        ),
      ],
      verify: (_) {
        verify(
          () => mockUsersCubit.updateUserPermissions(
            tUser.id,
            any(),
            groupId: tUser.permissionGroupId,
            workOrders: any(named: 'workOrders'),
          ),
        ).called(1);
      },
    );

    group('PermissionsCubit Group Work Orders Logic', () {
      blocTest<PermissionsCubit, PermissionsState>(
        'changeGroupWorkOrdersReadScope updates draftGroupWorkOrders readScope',
        build: () => cubit..initGroup(tGroup),
        act: (c) => c.changeGroupWorkOrdersReadScope(WorkOrderReadScope.all),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftGroupWorkOrders.readScope,
            'readScope',
            WorkOrderReadScope.all,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleGroupWorkOrdersCreate updates draftGroupWorkOrders create',
        build: () => cubit..initGroup(tGroup),
        act: (c) => c.toggleGroupWorkOrdersCreate(true),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftGroupWorkOrders.create,
            'create',
            true,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'changeGroupWorkOrdersUpdateScope updates draftGroupWorkOrders updateScope',
        build: () => cubit..initGroup(tGroup),
        act: (c) =>
            c.changeGroupWorkOrdersUpdateScope(WorkOrderUpdateScope.own),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftGroupWorkOrders.updateScope,
            'updateScope',
            WorkOrderUpdateScope.own,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleGroupWorkOrdersDelete updates draftGroupWorkOrders delete',
        build: () => cubit..initGroup(tGroup),
        act: (c) => c.toggleGroupWorkOrdersDelete(true),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftGroupWorkOrders.delete,
            'delete',
            true,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleGroupWorkOrdersChangeStatus updates draftGroupWorkOrders changeStatus',
        build: () => cubit..initGroup(tGroup),
        act: (c) => c.toggleGroupWorkOrdersChangeStatus(false),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftGroupWorkOrders.changeStatus,
            'changeStatus',
            false,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleGroupWorkOrdersReassign updates draftGroupWorkOrders reassign',
        build: () => cubit..initGroup(tGroup),
        act: (c) => c.toggleGroupWorkOrdersReassign(true),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftGroupWorkOrders.reassign,
            'reassign',
            true,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleGroupWorkOrdersmanagePendingRequests updates draftGroupWorkOrders managePendingRequests',
        build: () => cubit..initGroup(tGroup),
        act: (c) => c.toggleGroupWorkOrdersmanagePendingRequests(true),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftGroupWorkOrders.managePendingRequests,
            'managePendingRequests',
            true,
          ),
        ],
      );
    });

    group('PermissionsCubit User Work Orders Overrides Logic', () {
      blocTest<PermissionsCubit, PermissionsState>(
        'changeUserWorkOrdersReadScope updates draftUserWorkOrders readScope override',
        build: () => cubit..initUser(tUser),
        act: (c) => c.changeUserWorkOrdersReadScope(WorkOrderReadScope.all),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftUserWorkOrders.readScope,
            'readScope override',
            WorkOrderReadScope.all,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleUserWorkOrdersCreate updates draftUserWorkOrders create override',
        build: () => cubit..initUser(tUser),
        act: (c) => c.toggleUserWorkOrdersCreate(false),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftUserWorkOrders.create,
            'create override',
            false,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'changeUserWorkOrdersUpdateScope updates draftUserWorkOrders updateScope override',
        build: () => cubit..initUser(tUser),
        act: (c) => c.changeUserWorkOrdersUpdateScope(WorkOrderUpdateScope.own),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftUserWorkOrders.updateScope,
            'updateScope override',
            WorkOrderUpdateScope.own,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleUserWorkOrdersDelete updates draftUserWorkOrders delete override',
        build: () => cubit..initUser(tUser),
        act: (c) => c.toggleUserWorkOrdersDelete(true),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftUserWorkOrders.delete,
            'delete override',
            true,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleUserWorkOrdersChangeStatus updates draftUserWorkOrders changeStatus override',
        build: () => cubit..initUser(tUser),
        act: (c) => c.toggleUserWorkOrdersChangeStatus(true),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftUserWorkOrders.changeStatus,
            'changeStatus override',
            true,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleUserWorkOrdersReassign updates draftUserWorkOrders reassign override',
        build: () => cubit..initUser(tUser),
        act: (c) => c.toggleUserWorkOrdersReassign(false),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftUserWorkOrders.reassign,
            'reassign override',
            false,
          ),
        ],
      );

      blocTest<PermissionsCubit, PermissionsState>(
        'toggleUserWorkOrdersmanagePendingRequests updates draftUserWorkOrders managePendingRequests override',
        build: () => cubit..initUser(tUser),
        act: (c) => c.toggleUserWorkOrdersmanagePendingRequests(true),
        expect: () => [
          isA<PermissionsState>().having(
            (s) => s.draftUserWorkOrders.managePendingRequests,
            'managePendingRequests override',
            true,
          ),
        ],
      );
    });
  });
}
