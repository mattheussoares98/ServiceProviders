import 'dart:io';

import 'integration_recovery.dart';

/// Tracks only exact IDs registered by this test process; unresolved IDs persist.
class IntegrationDataTracker {
  IntegrationDataTracker(this.ledger);

  static final instance = IntegrationDataTracker(
    IntegrationRecovery(File('.integration-test-state/fixtures-$pid.json')),
  );

  final IntegrationRecovery ledger;

  void track(String table, String id) {
    final key = '$table/$id';
    if (!ledger.read().containsKey(key)) {
      ledger.put(key, {'table': table, 'id': id});
    }
  }

  List<String> getIds(String table) => ledger
      .read()
      .values
      .where((entry) => entry['table'] == table)
      .map((entry) => entry['id'] as String)
      .toList();

  Map<String, List<String>> get all {
    final result = <String, List<String>>{};
    for (final entry in ledger.read().values) {
      result
          .putIfAbsent(entry['table'] as String, () => [])
          .add(entry['id'] as String);
    }
    return result;
  }

  void resolved(String table, String id) => ledger.remove('$table/$id');
}
