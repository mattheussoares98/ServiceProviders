import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

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
              true,
            ),
      ],
    );

    blocTest<PermissionsCubit, PermissionsState>(
      'toggleGroupPermission updates localGroupPermissions',
      build: () => cubit..initGroup(tGroup),
      act: (c) => c.toggleGroupPermission(
        ResourceType.workOrders,
        PermissionAction.delete,
        true,
      ),
      expect: () => [
        isA<PermissionsState>().having(
          (s) => s.draftGroupPermissions[ResourceType.workOrders],
          'actions list',
          {
            PermissionAction.create,
            PermissionAction.update,
            PermissionAction.delete,
          },
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
            .having((s) => s.selectedGroupId, 'selectedGroupId', tUser.permissionGroupId),
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
        ..setUserPermissionOverride(ResourceType.workOrders, PermissionAction.create, true),
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
            .having((s) => s.selectedGroupId, 'selectedGroupId', 'admin-group-id')
            .having((s) => s.isAdmin, 'isAdmin', true)
            .having((s) => s.draftUserPermissions, 'draftUserPermissions', const <ResourceType, Map<PermissionAction, bool?>>{}),
      ],
    );

    group('isGroupAdmin', () {
      test('returns true when group name is "Administrador" (case-insensitive)', () {
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
      });

      test('returns false when group name is not "Administrador" or group is not found/null', () {
        final groups = [
          EntityFactory.makePermissionGroupEntity().copyWith(
            id: 'normal-id',
            name: 'Normal Group',
          ),
        ];

        expect(cubit.isGroupAdmin('normal-id', groups), isFalse);
        expect(cubit.isGroupAdmin('unknown-id', groups), isFalse);
        expect(cubit.isGroupAdmin(null, groups), isFalse);
      });
    });

    blocTest<PermissionsCubit, PermissionsState>(
      'setUserPermissionOverride updates state overrides',
      build: () => cubit..initUser(tUser),
      act: (c) => c.setUserPermissionOverride(
        ResourceType.workOrders,
        PermissionAction.create,
        true,
      ),
      expect: () => [
        isA<PermissionsState>().having(
          (s) =>
              s.draftUserPermissions[ResourceType.workOrders]?[PermissionAction
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
          () => mockUsersCubit.updateUserPermissions(any(), any(), groupId: any(named: 'groupId')),
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
        verify(() => mockUsersCubit.updateUserPermissions(tUser.id, any(), groupId: tUser.permissionGroupId)).called(1);
      },
    );
  });
}
