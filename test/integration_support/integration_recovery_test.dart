// Targeted flutter analyze passed; live tests were disabled.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../integration/core/integration_data_tracker.dart';
import '../integration/core/integration_recovery.dart';

void main() {
  late Directory directory;
  late IntegrationRecovery ledger;
  setUp(() {
    directory = Directory.systemTemp.createTempSync('validation-recovery-');
    ledger = IntegrationRecovery(File('${directory.path}/ledger.json'));
  });
  tearDown(() => directory.deleteSync(recursive: true));

  test('fresh process can read exact pending IDs after interruption', () {
    ledger.put('profile', {
      'originalGroupId': 'original',
      'profileId': 'profile',
    });
    final restarted = IntegrationRecovery(ledger.file);
    expect(restarted.read()['profile']?['originalGroupId'], 'original');
  });
  test('an unresolved original value cannot be overwritten', () {
    ledger.put('profile', {'originalGroupId': 'original'});
    expect(
      () => ledger.put('profile', {'originalGroupId': 'temporary'}),
      throwsStateError,
    );
    expect(ledger.read()['profile']?['originalGroupId'], 'original');
  });
  test(
    'failed recovery remains durable while successful entries resolve',
    () async {
      ledger
        ..put('a', {'id': 'a'})
        ..put('b', {'id': 'b'});
      await expectLater(
        ledger.recover((entry) async {
          if (entry['id'] == 'a') throw StateError('connection lost');
        }),
        throwsStateError,
      );
      expect(IntegrationRecovery(ledger.file).read().keys, ['a']);
      await ledger.recover((_) async {});
      expect(ledger.read(), isEmpty);
    },
  );
  test('corrupt ledger cannot be discarded by a new write', () {
    ledger.file.writeAsStringSync('{interrupted');
    expect(() => ledger.put('new', {'id': 'new'}), throwsFormatException);
    expect(ledger.file.readAsStringSync(), '{interrupted');
  });
  test('tracking is deduplicated and resolves only one exact ID', () {
    final tracker = IntegrationDataTracker(ledger)
      ..track('locations', 'a')
      ..track('locations', 'a')
      ..track('locations', 'b')
      ..track('assets', 'a');
    expect(tracker.getIds('locations'), ['a', 'b']);
    tracker.resolved('locations', 'a');
    final restarted = IntegrationDataTracker(IntegrationRecovery(ledger.file));
    expect(restarted.getIds('locations'), ['b']);
    expect(restarted.getIds('assets'), ['a']);
  });
}
