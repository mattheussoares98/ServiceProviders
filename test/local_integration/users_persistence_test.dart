import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/users/data/data_sources/users_local_data_source.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/user_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  UsersLocalDataSourceImpl source() =>
      UsersLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'profile edits, optional clears, deactivation, and deletion persist per company',
    () async {
      final a = UserFactory.makeUserProfileEntity();
      final b = UserFactory.makeUserProfileEntity();
      expect(
        (await source().saveUserProfiles([
          UserProfileModel.fromEntity(a),
          UserProfileModel.fromEntity(b),
        ])).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getUserProfiles(a.companyId)).data!.single.id,
        a.id,
      );
      final changed = a.copyWith(
        name: 'Técnico revisado',
        isActive: false,
        annulPhone: true,
        annulAvatarUrl: true,
        annulPermissionGroupId: true,
      );
      expect(
        (await source().saveUserProfile(
          UserProfileModel.fromEntity(changed),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final row = (await source().getUserProfileById(a.id)).data!;
      expect(row.name, changed.name);
      expect(row.isActive, isFalse);
      expect(row.phone, isNull);
      expect(row.avatarUrl, isNull);
      expect(row.permissionGroupId, isNull);
      expect((await source().deleteUserProfile(a.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getUserProfiles(a.companyId)).data, isEmpty);
      expect(
        await source().getUserProfileById(a.id),
        isA<FailureState<UserProfileModel>>(),
      );
      expect(
        (await source().getUserProfiles(b.companyId)).data!.single.id,
        b.id,
      );
    },
  );

  test(
    'explicit user allow and deny overrides survive restart and can be removed',
    () async {
      final user = UserFactory.makeUserProfileEntity().copyWith(
        permissions: {
          ResourceType.attachments: {
            PermissionAction.read: true,
            PermissionAction.create: false,
            PermissionAction.delete: null,
          },
        },
      );
      expect(
        (await source().saveUserProfile(
          UserProfileModel.fromEntity(user),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      var row = (await source().getUserProfileById(user.id)).data!;
      expect(row.isAdmin, isFalse);
      expect(
        row.permissions[ResourceType.attachments]?[PermissionAction.read],
        isTrue,
      );
      expect(
        row.permissions[ResourceType.attachments]?[PermissionAction.create],
        isFalse,
      );
      expect(
        row.permissions[ResourceType.attachments]?[PermissionAction.delete],
        isNull,
      );
      expect(
        (await source().saveUserProfile(
          UserProfileModel.fromEntity(user.copyWith(permissions: {})),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      row = (await source().getUserProfileById(user.id)).data!;
      expect(row.permissions, isEmpty);
      expect(row.isAdmin, isFalse);
    },
  );

  test(
    'permission group rename, grant replacement, and deletion persist in the correct company',
    () async {
      final a = UserFactory.makePermissionGroupEntity();
      final b = UserFactory.makePermissionGroupEntity();
      expect(
        (await source().savePermissionGroups([
          PermissionGroupModel.fromEntity(a),
          PermissionGroupModel.fromEntity(b),
        ])).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getPermissionGroups(
          a.companyId,
        )).data!.single.permissions[ResourceType.attachments],
        contains(PermissionAction.delete),
      );
      final changed = a.copyWith(
        name: 'Somente leitura',
        permissions: {
          ResourceType.attachments: {PermissionAction.read},
        },
        rawPermissions: {},
        isDefault: true,
      );
      expect(
        (await source().savePermissionGroup(
          PermissionGroupModel.fromEntity(changed),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final row = (await source().getPermissionGroups(
        a.companyId,
      )).data!.single;
      expect(row.name, 'Somente leitura');
      expect(row.isDefault, isTrue);
      expect(row.permissions[ResourceType.attachments], {
        PermissionAction.read,
      });
      expect(row.workOrders, changed.workOrders);
      expect((await source().deletePermissionGroup(a.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getPermissionGroups(a.companyId)).data, isEmpty);
      expect(
        (await source().getPermissionGroups(b.companyId)).data!.single.id,
        b.id,
      );
    },
  );
}
