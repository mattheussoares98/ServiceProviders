import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/integration_run_summary.dart';

void main() {
  String events({
    String outcome = 'success',
    bool skipped = false,
    bool hidden = false,
    bool done = true,
  }) => [
    jsonEncode({
      'type': 'testStart',
      'test': {'id': 1, 'name': 'case'},
    }),
    jsonEncode({
      'type': 'testDone',
      'testID': 1,
      'result': outcome,
      'skipped': skipped,
      'hidden': hidden,
    }),
    if (done) jsonEncode({'type': 'done', 'success': outcome == 'success'}),
  ].join('\n');

  test('plain tests without catalogue JSON still count', () {
    final summary = IntegrationRunSummary.parse(events());
    expect(summary.passed, isTrue);
    expect(summary.records, hasLength(1));
  });
  test('failing assertion cannot be hidden by a completed runner', () {
    final summary = IntegrationRunSummary.parse(events(outcome: 'failure'));
    expect(summary.passed, isFalse);
    expect(summary.records.single['outcome'], 'failed');
  });
  test('required skipped cases are never passes', () {
    expect(IntegrationRunSummary.parse(events(skipped: true)).passed, isFalse);
  });
  test('zero tests and successful hidden loading tests are not coverage', () {
    expect(IntegrationRunSummary.parse('').passed, isFalse);
    expect(IntegrationRunSummary.parse(events(hidden: true)).passed, isFalse);
  });
  test('setup and loading failures are retained even if hidden', () {
    final summary = IntegrationRunSummary.parse(
      events(hidden: true, outcome: 'error'),
    );
    expect(summary.passed, isFalse);
    expect(summary.records.single['outcome'], 'failed');
  });
  test('interrupted run cannot pass', () {
    expect(IntegrationRunSummary.parse(events(done: false)).passed, isFalse);
  });
  test('malformed trailing output fails integrity', () {
    expect(IntegrationRunSummary.parse('${events()}\n{').passed, isFalse);
  });
  test('started but unfinished test fails integrity', () {
    final input =
        '${events()}\n${jsonEncode({
          'type': 'testStart',
          'test': {'id': 2, 'name': 'unfinished'},
        })}';
    expect(IntegrationRunSummary.parse(input).passed, isFalse);
  });
  test('duplicate completion cannot inflate passing counts', () {
    final input =
        '${events()}\n${jsonEncode({'type': 'testDone', 'testID': 1, 'result': 'success'})}';
    final summary = IntegrationRunSummary.parse(input);
    expect(summary.passed, isFalse);
    expect(summary.records, hasLength(1));
  });
  test('asynchronous errors fail even when testDone says success', () {
    final input = '${events()}\n${jsonEncode({'type': 'error', 'testID': 1})}';
    expect(IntegrationRunSummary.parse(input).passed, isFalse);
  });
}
