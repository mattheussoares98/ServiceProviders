import 'dart:convert';

/// Authoritative accounting includes ordinary tests and setup/teardown failures.
class IntegrationRunSummary {
  final List<Map<String, Object?>> records = [];
  final List<String> problems = [];

  bool get passed =>
      problems.isEmpty &&
      records.isNotEmpty &&
      records.every((record) => record['outcome'] == 'passed');

  static IntegrationRunSummary parse(String input) {
    final result = IntegrationRunSummary();
    final started = <int, Map<String, Object?>>{};
    final completed = <int>{};
    var finished = false;
    for (final line in const LineSplitter().convert(input)) {
      if (line.trim().isEmpty) continue;
      Map<String, dynamic> event;
      try {
        event = jsonDecode(line) as Map<String, dynamic>;
      } on Object {
        result.problems.add('Malformed runner event');
        continue;
      }
      switch (event['type']) {
        case 'testStart':
          final test = Map<String, Object?>.from(event['test'] as Map);
          started[test['id']! as int] = test;
        case 'testDone':
          final id = event['testID'] as int;
          final test = started[id];
          if (test == null || !completed.add(id)) {
            result.problems.add('Unknown or duplicate completed test: $id');
            continue;
          }
          final success = event['result'] == 'success';
          if (event['hidden'] == true && success) continue;
          result.records.add({
            'id': 'runner-$id',
            'description': test['name'],
            'feature': 'Runner cases (including setup/teardown)',
            'layer': 'integration',
            'outcome': event['skipped'] == true
                ? 'skipped'
                : success
                ? 'passed'
                : 'failed',
          });
        case 'error':
          result.problems.add('Runner error for test ${event['testID']}');
        case 'done':
          finished = true;
          if (event['success'] != true) {
            result.problems.add('Flutter reported unsuccessful execution');
          }
      }
    }
    if (!finished) result.problems.add('Runner did not finish');
    if (started.keys.any((id) => !completed.contains(id))) {
      result.problems.add('Started tests are missing completion events');
    }
    if (result.records.isEmpty) {
      result.problems.add('No executable tests completed');
    }
    return result;
  }
}
