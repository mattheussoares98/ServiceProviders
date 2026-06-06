import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/clients/local/local_storage_client.dart';
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late LocalStorageClientImpl localStorageClient;

  setUpAll(() async {
    await dotenv.load();
    dotenv.env['ENCRYPTION_KEY'] = 'supersecret32charkey123456789012';
  });

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    localStorageClient = LocalStorageClientImpl(database: database);
    await localStorageClient.init();
  });

  tearDown(() async {
    await database.close();
  });

  group('LocalStorageClientImpl', () {
    test('getString returns value from Drift after setting it', () async {
      await localStorageClient.setString('key', 'value');

      final result = localStorageClient.getString('key');

      expect(result, 'value');
    });

    test('getString returns null if key does not exist', () {
      final result = localStorageClient.getString('missing');

      expect(result, isNull);
    });

    test('setString saves to cache and database', () async {
      await localStorageClient.setString('key', 'value');

      // Check cache
      expect(localStorageClient.getString('key'), 'value');

      // Check database directly
      final dbValue = await (database.select(database.localStorageItems)
            ..where((t) => t.key.equals('key')))
          .getSingleOrNull();
      expect(dbValue?.value, 'value');
    });

    test('setStringWithEncryption encrypts and saves value', () async {
      await localStorageClient.setStringWithEncryption('key', 'sensitive');

      // Decrypt and check
      final result = localStorageClient.getEncryptedString('key');
      expect(result, 'sensitive');
    });

    test('remove deletes from cache and database', () async {
      await localStorageClient.setString('key', 'value');
      await localStorageClient.remove('key');

      expect(localStorageClient.getString('key'), isNull);

      final dbValue = await (database.select(database.localStorageItems)
            ..where((t) => t.key.equals('key')))
          .getSingleOrNull();
      expect(dbValue, isNull);
    });

    test('clear deletes all from cache and database', () async {
      await localStorageClient.setString('key1', 'value1');
      await localStorageClient.setString('key2', 'value2');

      await localStorageClient.clear();

      expect(localStorageClient.getString('key1'), isNull);
      expect(localStorageClient.getString('key2'), isNull);

      final dbValues = await database.select(database.localStorageItems).get();
      expect(dbValues, isEmpty);
    });
  });
}
