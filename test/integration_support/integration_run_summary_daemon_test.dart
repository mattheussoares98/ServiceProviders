import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/integration_run_summary.dart';

void main() {
  // Envelope shape observed in the actual Flutter machine log from readiness.
  final daemon = jsonEncode([
    {
      'event': 'test.startedProcess',
      'params': {'vmServiceUri': 'http://127.0.0.1:1234/fake'},
    },
  ]);
  String run(String outcome) => [
    daemon,
    jsonEncode({
      'type': 'testStart',
      'test': {'id': 1, 'name': 'ordinary test'},
    }),
    jsonEncode({
      'type': 'testDone',
      'testID': 1,
      'result': outcome,
      'skipped': false,
      'hidden': false,
    }),
    jsonEncode({'type': 'done', 'success': outcome == 'success'}),
  ].join('\n');

  test('valid Flutter daemon envelope does not invalidate a passing run', () {
    final summary = IntegrationRunSummary.parse(run('success'));
    expect(summary.records, hasLength(1));
    expect(summary.records.single['outcome'], 'passed');
    expect(summary.problems, isEmpty);
    expect(summary.passed, isTrue);
  });

  test('daemon metadata never hides a real failed test', () {
    final summary = IntegrationRunSummary.parse(run('failure'));
    expect(summary.records, hasLength(1));
    expect(summary.records.single['outcome'], 'failed');
    expect(summary.passed, isFalse);
  });

  test('truncated daemon JSON still invalidates an otherwise passing run', () {
    final summary = IntegrationRunSummary.parse('${run('success')}\n[{');
    expect(summary.problems, contains('Malformed runner event'));
    expect(summary.passed, isFalse);
  });
}
