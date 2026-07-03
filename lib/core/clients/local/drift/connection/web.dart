import 'dart:async';
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

QueryExecutor connect() {
  return LazyDatabase(() async {
    try {
      final result = await WasmDatabase.open(
        databaseName: 'app',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('WasmDatabase initialization timed out'),
      );
      return result.resolvedExecutor;
    } catch (_) {
      try {
        final sqlite3 = await WasmSqlite3.loadFromUrlString('sqlite3.wasm');
        sqlite3.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
        return WasmDatabase.inMemory(sqlite3);
      } catch (e) {
        rethrow;
      }
    }
  });
}
