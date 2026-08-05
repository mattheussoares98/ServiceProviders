import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';

import '../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late LocalStorageClientImpl localStorageClient;

  setUpAll(() async {
    await dotenv.load();
    dotenv.env['ENCRYPTION_KEY'] = 'supersecret32charkey123456789012';
  });

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    localStorageClient = LocalStorageClientImpl(database: database);
    await localStorageClient.init();
  });

  tearDown(() async {
    await database.close();
  });

  group('LocalStorageClientImpl — Theme Mode', () {
    test('getThemeMode defaults to system', () {
      expect(localStorageClient.getThemeMode(), 'system');
    });

    test('saveThemeMode persists value and updates cache', () async {
      final newTheme = faker.randomGenerator.element([
        'light',
        'dark',
        'system',
      ]);
      await localStorageClient.saveThemeMode(newTheme);

      expect(localStorageClient.getThemeMode(), newTheme);

      // Check database
      final dbValue = await (database.select(
        database.appSettings,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
      expect(dbValue?.themeMode, newTheme);
    });
  });

  group('LocalStorageClientImpl — Selected Mode', () {
    test('getSelectedMode defaults to null', () {
      expect(localStorageClient.getSelectedMode(), isNull);
    });

    test('saveSelectedMode persists value and updates cache', () async {
      final newMode = faker.randomGenerator.element([
        'provider',
        'client',
        null,
      ]);
      await localStorageClient.saveSelectedMode(newMode);

      expect(localStorageClient.getSelectedMode(), newMode);

      // Check database
      final dbValue = await (database.select(
        database.appSettings,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
      expect(dbValue?.selectedMode, newMode);
    });

    test('init restores selectedMode from database', () async {
      await localStorageClient.saveSelectedMode('provider');

      final secondClient = LocalStorageClientImpl(database: database);
      await secondClient.init();

      expect(secondClient.getSelectedMode(), 'provider');
    });
  });

  group('LocalStorageClientImpl — Selected Company ID', () {
    test('getSelectedCompanyId defaults to null', () {
      expect(localStorageClient.getSelectedCompanyId(), isNull);
    });

    test('saveSelectedCompanyId persists value and updates cache', () async {
      final companyId = faker.guid.guid();
      await localStorageClient.saveSelectedCompanyId(companyId);

      expect(localStorageClient.getSelectedCompanyId(), companyId);

      // Check database
      final dbValue = await (database.select(
        database.appSettings,
      )..where((t) => t.id.equals(1))).getSingleOrNull();
      expect(dbValue?.selectedCompanyId, companyId);
    });

    test('init restores selectedCompanyId from database', () async {
      final companyId = faker.guid.guid();
      await localStorageClient.saveSelectedCompanyId(companyId);

      final secondClient = LocalStorageClientImpl(database: database);
      await secondClient.init();

      expect(secondClient.getSelectedCompanyId(), companyId);
    });
  });

  group('LocalStorageClientImpl — User Session', () {
    test('getUserSession returns null initially', () {
      expect(localStorageClient.getUserSession(), isNull);
    });

    test('saveUserSession persists value and updates cache', () async {
      final userSession = UserDataEntity(
        user: EntityFactory.makeUserProfileEntity().copyWith(
          isActive: faker.randomGenerator.boolean(),
        ),
        accessToken: faker.jwt.valid(),
        refreshToken: faker.jwt.valid(),
      );

      await localStorageClient.saveUserSession(userSession);

      expect(localStorageClient.getUserSession(), userSession);

      // Check database
      final dbValue = await database
          .select(database.userSessions)
          .getSingleOrNull();
      expect(dbValue, isNotNull);
      expect(dbValue!.id, userSession.user.id);
      expect(dbValue.name, userSession.user.name);
      expect(dbValue.email, userSession.user.email);
      expect(dbValue.isActive, userSession.user.isActive);
      expect(dbValue.accessToken, userSession.accessToken);
      expect(dbValue.refreshToken, userSession.refreshToken);
    });

    test('clearUserSession deletes session from cache and database', () async {
      final userSession = UserDataEntity(
        user: EntityFactory.makeUserProfileEntity().copyWith(isActive: true),
        accessToken: faker.jwt.valid(),
        refreshToken: faker.jwt.valid(),
      );

      await localStorageClient.saveUserSession(userSession);
      await localStorageClient.clearUserSession();

      expect(localStorageClient.getUserSession(), isNull);

      final dbValue = await database
          .select(database.userSessions)
          .getSingleOrNull();
      expect(dbValue, isNull);
    });

    test('saveUserSession replaces any previous session row', () async {
      final firstSession = UserDataEntity(
        user: EntityFactory.makeUserProfileEntity().copyWith(isActive: true),
        accessToken: faker.jwt.valid(),
        refreshToken: faker.jwt.valid(),
      );
      final secondSession = UserDataEntity(
        user: EntityFactory.makeUserProfileEntity().copyWith(isActive: true),
        accessToken: faker.jwt.valid(),
        refreshToken: faker.jwt.valid(),
      );

      await localStorageClient.saveUserSession(firstSession);
      await localStorageClient.saveUserSession(secondSession);

      final dbSessions = await database.select(database.userSessions).get();
      expect(dbSessions, hasLength(1));
      expect(dbSessions.single.id, secondSession.user.id);
      expect(localStorageClient.getUserSession(), secondSession);
    });

    test(
      'init restores userSession for Service Provider when user profile is absent in userProfiles table',
      () async {
        final providerSession = UserDataEntity(
          user: EntityFactory.makeUserProfileEntity().copyWith(
            companyId: '',
            isActive: true,
          ),
          accessToken: faker.jwt.valid(),
          refreshToken: faker.jwt.valid(),
        );

        await localStorageClient.saveUserSession(providerSession);

        final secondClient = LocalStorageClientImpl(database: database);
        await secondClient.init();

        final restored = secondClient.getUserSession();
        expect(restored, isNotNull);
        expect(restored!.user.id, providerSession.user.id);
        expect(restored.user.companyId, '');
        expect(restored.user.name, providerSession.user.name);
        expect(restored.user.email, providerSession.user.email);
        expect(restored.accessToken, providerSession.accessToken);
        expect(restored.refreshToken, providerSession.refreshToken);
      },
    );

    test(
      'init restores userSession when user profile exists in userProfiles table',
      () async {
        final userProfile = EntityFactory.makeUserProfileEntity();
        final userSession = UserDataEntity(
          user: userProfile,
          accessToken: faker.jwt.valid(),
          refreshToken: faker.jwt.valid(),
        );

        await localStorageClient.saveUserSession(userSession);
        // Save user profile in local database table
        await database
            .into(database.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: userProfile.id,
                companyId: userProfile.companyId,
                name: userProfile.name,
                email: userProfile.email,
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );

        final secondClient = LocalStorageClientImpl(database: database);
        await secondClient.init();

        final restored = secondClient.getUserSession();
        expect(restored, isNotNull);
        expect(restored!.user.id, userProfile.id);
        expect(restored.user.companyId, userProfile.companyId);
        expect(restored.user.name, userProfile.name);
        expect(restored.accessToken, userSession.accessToken);
      },
    );
  });

  group('LocalStorageClientImpl — Global operations', () {
    test('clearAll wipes both settings and sessions', () async {
      final userSession = UserDataEntity(
        user: EntityFactory.makeUserProfileEntity().copyWith(isActive: true),
        accessToken: faker.jwt.valid(),
        refreshToken: faker.jwt.valid(),
      );

      await localStorageClient.saveThemeMode('dark');
      await localStorageClient.saveSelectedMode('provider');
      await localStorageClient.saveSelectedCompanyId(faker.guid.guid());
      await localStorageClient.saveUserSession(userSession);

      await localStorageClient.clearAll();

      expect(localStorageClient.getThemeMode(), 'system');
      expect(localStorageClient.getSelectedMode(), isNull);
      expect(localStorageClient.getSelectedCompanyId(), isNull);
      expect(localStorageClient.getUserSession(), isNull);

      final dbSettings = await database.select(database.appSettings).get();
      expect(dbSettings, isEmpty);

      final dbSessions = await database.select(database.userSessions).get();
      expect(dbSessions, isEmpty);
    });
  });
}
