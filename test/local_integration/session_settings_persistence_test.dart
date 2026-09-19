import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/features/users/data/data_sources/users_local_data_source.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/user_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  late LocalStorageClientImpl client;
  Future<void> restart() async {
    await fixture.reopen();
    client = LocalStorageClientImpl(database: fixture.database);
    await client.init();
  }

  setUp(() async {
    fixture = LocalDatabaseFixture();
    client = LocalStorageClientImpl(database: fixture.database);
    await client.init();
  });
  tearDown(() => fixture.dispose());

  test(
    'saving individual preferences preserves the others after restart',
    () async {
      final companyId = UserFactory.makeCompanyEntity().id;
      await client.saveThemeMode('dark');
      await client.savePushNotifications(false);
      await client.saveSelectedMode('provider');
      await client.saveSelectedCompanyId(companyId);
      await restart();
      expect(client.getThemeMode(), 'dark');
      expect(client.getPushNotifications(), isFalse);
      expect(client.getSelectedMode(), 'provider');
      expect(client.getSelectedCompanyId(), companyId);
      await client.saveThemeMode('light');
      await restart();
      expect(client.getThemeMode(), 'light');
      expect(client.getPushNotifications(), isFalse);
      expect(client.getSelectedCompanyId(), companyId);
    },
  );

  test(
    'clearing selected mode and company persists without resetting preferences',
    () async {
      await client.saveThemeMode('dark');
      await client.saveSelectedMode('provider');
      await client.saveSelectedCompanyId(UserFactory.makeCompanyEntity().id);
      await restart();
      await client.saveSelectedMode(null);
      await client.saveSelectedCompanyId(null);
      await restart();
      expect(client.getSelectedMode(), isNull);
      expect(client.getSelectedCompanyId(), isNull);
      expect(client.getThemeMode(), 'dark');
    },
  );

  test(
    'replacing the session restores only the latest user and tokens',
    () async {
      final a = UserFactory.makeUserDataEntity().copyWith(
        accessToken: 'fake-access-a',
        refreshToken: 'fake-refresh-a',
      );
      final b = UserFactory.makeUserDataEntity().copyWith(
        accessToken: 'fake-access-b',
        refreshToken: 'fake-refresh-b',
      );
      final users = UsersLocalDataSourceImpl(database: fixture.database);
      expect(
        (await users.saveUserProfiles([
          UserProfileModel.fromEntity(a.user),
          UserProfileModel.fromEntity(b.user),
        ])).data,
        isTrue,
      );
      await client.saveUserSession(a);
      await restart();
      expect(client.getUserSession()!.user.id, a.user.id);
      await client.saveUserSession(b);
      await restart();
      final restored = client.getUserSession()!;
      expect(restored.user.id, b.user.id);
      expect(restored.user.companyId, b.user.companyId);
      expect(restored.accessToken, 'fake-access-b');
      expect(restored.refreshToken, 'fake-refresh-b');
      expect(
        await fixture.database.select(fixture.database.userSessions).get(),
        hasLength(1),
      );
    },
  );

  test(
    'clearing the session removes tokens durably and preserves theme',
    () async {
      await client.saveThemeMode('dark');
      await client.saveUserSession(
        UserFactory.makeUserDataEntity().copyWith(
          accessToken: 'fake-access',
          refreshToken: 'fake-refresh',
        ),
      );
      await restart();
      expect(client.getUserSession(), isNotNull);
      await client.clearUserSession();
      await restart();
      expect(client.getUserSession(), isNull);
      expect(
        await fixture.database.select(fixture.database.userSessions).get(),
        isEmpty,
      );
      expect(client.getThemeMode(), 'dark');
    },
  );

  test(
    'clearAll leaves the same notification preference before and after restart',
    () async {
      await client.savePushNotifications(false);
      await client.clearAll();
      final beforeRestart = client.getPushNotifications();
      await restart();
      expect(
        client.getPushNotifications(),
        beforeRestart,
        reason:
            'Restart must not silently change the preference produced by clearAll.',
      );
    },
  );

  test(
    'failed preference persistence does not change the last saved in-memory value',
    () async {
      await client.saveThemeMode('dark');
      final closedClient = client;
      await fixture.reopen();
      await expectLater(closedClient.saveThemeMode('light'), throwsA(anything));
      expect(
        closedClient.getThemeMode(),
        'dark',
        reason:
            'The save failed; the client must not expose an uncommitted preference as saved.',
      );
    },
  );
}
