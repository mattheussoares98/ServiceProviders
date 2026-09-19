import 'dart:io';

import 'package:drift/native.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';

/// A disposable local database that can be closed and reopened independently.
class LocalDatabaseFixture {
  LocalDatabaseFixture()
    : directory = Directory.systemTemp.createTempSync(
        'servicepro-persistence-',
      );

  final Directory directory;
  AppDatabase? _database;

  AppDatabase get database => _database ??= AppDatabase.forTesting(
    NativeDatabase(File('${directory.path}/fixture.sqlite')),
  );

  Future<void> reopen() async {
    await _database?.close();
    _database = null;
  }

  Future<void> dispose() async {
    await reopen();
    directory.deleteSync(recursive: true);
  }
}
