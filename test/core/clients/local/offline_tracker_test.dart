import 'dart:async';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/core/constants/offline_limits.dart';

import '../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late StreamController<InternetStatus> connectivityController;
  late AppDatabase database;
  late OfflineTrackerImpl tracker;

  setUp(() {
    mockInternetClient = MockInternetClient();
    connectivityController = StreamController<InternetStatus>.broadcast();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    when(
      () => mockInternetClient.connectivityStream,
    ).thenAnswer((_) => connectivityController.stream);
    when(() => mockInternetClient.isConnected).thenReturn(false);

    tracker = OfflineTrackerImpl(
      internetClient: mockInternetClient,
      database: database,
    );
  });

  tearDown(() async {
    tracker.dispose();
    await connectivityController.close();
    await database.close();
  });

  group('OfflineTracker', () {
    test('does nothing when online', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      tracker.init();

      await database
          .into(database.syncAuditLogs)
          .insert(
            const SyncAuditLogsCompanion(
              id: Value('1'),
              companyId: Value('c-1'),
              userProfileId: Value('u-1'),
              entityType: Value('work_order'),
              entityId: Value('wo-1'),
              operation: Value('create'),
              payload: Value('{}'),
              status: Value('pending'),
            ),
          );
      await pumpEventQueue();

      expect(tracker.offlineMutationCount, equals(1));
      expect(tracker.checkStartupOrResumeStatus(), isFalse);
    });

    test(
      'tracks offline actions reactively via Drift and triggers alert at limit and throttle frequency',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        tracker.init();

        final events = <OfflineAdvisoryEvent>[];
        final sub = tracker.alertStream.listen(events.add);

        // Insert items up to limit - 1
        for (var i = 1; i < kMaxOfflinePendingRequests; i++) {
          await database
              .into(database.syncAuditLogs)
              .insert(
                SyncAuditLogsCompanion(
                  id: Value('$i'),
                  companyId: const Value('c-1'),
                  userProfileId: const Value('u-1'),
                  entityType: const Value('work_order'),
                  entityId: Value('wo-$i'),
                  operation: const Value('create'),
                  payload: const Value('{}'),
                  status: const Value('pending'),
                ),
              );
        }
        await pumpEventQueue();

        expect(
          tracker.offlineMutationCount,
          equals(kMaxOfflinePendingRequests - 1),
        );
        expect(events, isEmpty);

        // Insert 10th item (hits limit)
        await database
            .into(database.syncAuditLogs)
            .insert(
              const SyncAuditLogsCompanion(
                id: Value('10'),
                companyId: Value('c-1'),
                userProfileId: Value('u-1'),
                entityType: Value('work_order'),
                entityId: Value('wo-10'),
                operation: Value('create'),
                payload: Value('{}'),
                status: Value('pending'),
              ),
            );
        await pumpEventQueue();

        expect(tracker.offlineMutationCount, equals(10));
        expect(events.length, equals(1));
        expect(events.first.trigger, equals(OfflineAdvisoryTrigger.action));
        expect(events.first.hasBreachedRequests, isTrue);

        // Insert 11th and 12th items (throttled)
        for (var i = 11; i <= 12; i++) {
          await database
              .into(database.syncAuditLogs)
              .insert(
                SyncAuditLogsCompanion(
                  id: Value('$i'),
                  companyId: const Value('c-1'),
                  userProfileId: const Value('u-1'),
                  entityType: const Value('work_order'),
                  entityId: Value('wo-$i'),
                  operation: const Value('create'),
                  payload: const Value('{}'),
                  status: const Value('pending'),
                ),
              );
        }
        await pumpEventQueue();
        expect(events.length, equals(1));

        // Insert 13th item (10 + 3 => throttle threshold reached)
        await database
            .into(database.syncAuditLogs)
            .insert(
              const SyncAuditLogsCompanion(
                id: Value('13'),
                companyId: Value('c-1'),
                userProfileId: Value('u-1'),
                entityType: Value('work_order'),
                entityId: Value('wo-13'),
                operation: Value('create'),
                payload: Value('{}'),
                status: Value('pending'),
              ),
            );
        await pumpEventQueue();

        expect(events.length, equals(2));
        expect(tracker.lastAlertMutationCount, equals(13));

        await sub.cancel();
      },
    );

    test(
      'checkStartupOrResumeStatus returns true when threshold is breached',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        tracker.init();

        expect(tracker.checkStartupOrResumeStatus(), isFalse);

        for (var i = 1; i <= kMaxOfflinePendingRequests; i++) {
          await database
              .into(database.syncAuditLogs)
              .insert(
                SyncAuditLogsCompanion(
                  id: Value('$i'),
                  companyId: const Value('c-1'),
                  userProfileId: const Value('u-1'),
                  entityType: const Value('work_order'),
                  entityId: Value('wo-$i'),
                  operation: const Value('create'),
                  payload: const Value('{}'),
                  status: const Value('pending'),
                ),
              );
        }
        await pumpEventQueue();

        expect(tracker.checkStartupOrResumeStatus(), isTrue);
      },
    );

    test(
      'resets counters when reset is called or internet reconnects',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        tracker.init();

        for (var i = 1; i <= 5; i++) {
          await database
              .into(database.syncAuditLogs)
              .insert(
                SyncAuditLogsCompanion(
                  id: Value('$i'),
                  companyId: const Value('c-1'),
                  userProfileId: const Value('u-1'),
                  entityType: const Value('work_order'),
                  entityId: Value('wo-$i'),
                  operation: const Value('create'),
                  payload: const Value('{}'),
                  status: const Value('pending'),
                ),
              );
        }
        await pumpEventQueue();
        expect(tracker.offlineMutationCount, equals(5));

        // Reconnect
        connectivityController.add(InternetStatus.connected);
        await pumpEventQueue();

        expect(tracker.offlineMutationCount, equals(0));
        expect(tracker.offlineSince, isNull);
      },
    );
  });
}
