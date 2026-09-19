import 'dart:convert';
import 'dart:io';

/// Durable exact-ID recovery state; never stored in disposable build reports.
class IntegrationRecovery {
  const IntegrationRecovery(this.file);

  final File file;

  Map<String, Map<String, dynamic>> read() {
    if (!file.existsSync()) return {};
    final value = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return value.map(
      (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
    );
  }

  void put(String key, Map<String, dynamic> entry) {
    final entries = read();
    if (entries.containsKey(key)) {
      throw StateError('Unresolved recovery entry already exists: $key');
    }
    entries[key] = entry;
    _write(entries);
  }

  void remove(String key) {
    final entries = read()..remove(key);
    _write(entries);
  }

  Future<void> recover(
    Future<void> Function(Map<String, dynamic>) restore,
  ) async {
    final failed = <String>[];
    for (final entry in read().entries) {
      try {
        await restore(entry.value);
        remove(entry.key);
      } on Object {
        failed.add(entry.key);
      }
    }
    if (failed.isNotEmpty) {
      throw StateError(
        'Recovery incomplete; retained IDs: ${failed.join(', ')}',
      );
    }
  }

  void _write(Map<String, Map<String, dynamic>> entries) {
    file.parent.createSync(recursive: true);
    File('${file.path}.tmp')
      ..writeAsStringSync(jsonEncode(entries), flush: true)
      ..renameSync(file.path);
  }
}
