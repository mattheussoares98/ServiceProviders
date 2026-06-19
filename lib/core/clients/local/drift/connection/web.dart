import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:drift/web.dart';

QueryExecutor connect() {
  return LazyDatabase(() async {
    try {
      final result = await WasmDatabase.open(
        databaseName: 'app',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    } catch (_) {
      return WebDatabase.withStorage(DriftWebStorage.volatile());
    }
  });
}
