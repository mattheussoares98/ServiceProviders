import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/utils/encryption/encryption_utils.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

abstract interface class LocalStorageClient {
  Future<void> setString(String key, String value);
  Future<void> setStringWithEncryption(String key, String value);
  String? getString(String key);
  String? getEncryptedString(String key);
  bool has(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

@module
abstract class LocalStorageClientModule {
  @preResolve //It tells GetIt that it must await the asynchronous setup (init()) of LocalStorageClientImpl before finalizing the application startup. This ensures that the key-value cache is fully loaded into memory before any screen or HTTP interceptor attempts to read from it.
  Future<LocalStorageClient> provideLocalStorageClient(
    AppDatabase database,
  ) async {
    final client = LocalStorageClientImpl(database: database);
    await client.init();
    return client;
  }
}

final class LocalStorageClientImpl implements LocalStorageClient {
  LocalStorageClientImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;
  final Map<String, String> _cache = {};

  Future<void> init() async {
    final items = await _database.select(_database.localStorageItems).get();
    for (final item in items) {
      _cache[item.key] = item.value;
    }
  }

  @override
  Future<void> setString(String key, String value) async {
    _cache[key] = value;
    await _database
        .into(_database.localStorageItems)
        .insertOnConflictUpdate(
          LocalStorageItemsCompanion(key: Value(key), value: Value(value)),
        );
  }

  @override
  Future<void> setStringWithEncryption(String key, String value) async {
    final encryptedData = EncryptionUtils.encrypt(value);
    final encodedEncryption = jsonEncode(encryptedData.toJson());
    await setString(key, encodedEncryption);
  }

  @override
  String? getString(String key) => _cache[key];

  @override
  String? getEncryptedString(String key) {
    final encodedEncryption = getString(key);
    if (encodedEncryption == null) {
      return null;
    }
    final encryptionMap = jsonDecode(encodedEncryption) as MapDynamic;
    final encryptedData = EncryptedData.fromJson(encryptionMap);
    return EncryptionUtils.decrypt(encryptedData);
  }

  @override
  bool has(String key) => _cache.containsKey(key);

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
    await (_database.delete(
      _database.localStorageItems,
    )..where((t) => t.key.equals(key))).go();
  }

  @override
  Future<void> clear() async {
    _cache.clear();
    await _database.delete(_database.localStorageItems).go();
  }
}
