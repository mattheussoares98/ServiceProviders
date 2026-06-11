import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

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
  });

  group('LocalStorageClientImpl — Global operations', () {
    test('clearAll wipes both settings and sessions', () async {
      final userSession = UserDataEntity(
        user: EntityFactory.makeUserProfileEntity().copyWith(isActive: true),
        accessToken: faker.jwt.valid(),
        refreshToken: faker.jwt.valid(),
      );

      await localStorageClient.saveThemeMode('dark');
      await localStorageClient.saveUserSession(userSession);

      await localStorageClient.clearAll();

      expect(localStorageClient.getThemeMode(), 'system');
      expect(localStorageClient.getUserSession(), isNull);

      final dbSettings = await database.select(database.appSettings).get();
      expect(dbSettings, isEmpty);

      final dbSessions = await database.select(database.userSessions).get();
      expect(dbSessions, isEmpty);
    });
  });
}
