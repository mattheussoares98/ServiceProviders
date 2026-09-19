import 'dart:async';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/core/constants/offline_limits.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';

import '../../../../testing/mocks/client_mocks.dart';
import '../../../../testing/mocks/factories/user_factory.dart';
import '../../../../testing/mocks/repositories/auth_mocks.dart';
import '../../../../testing/mocks/use_cases/auth_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late StreamController<InternetStatus> connectivityController;
  late AppDatabase database;
  late OfflineTrackerImpl tracker;
  late MockSessionRepository sessionRepository;
  late MockGetActiveCompanyIdUseCase getActiveCompanyId;
  late StreamController<UserDataEntity> sessionController;
  late UserDataEntity session;
  late String activeCompanyId;

  setUp(() {
    mockInternetClient = MockInternetClient();
    connectivityController = StreamController<InternetStatus>.broadcast();
    database = AppDatabase.forTesting(NativeDatabase.memory());
    sessionRepository = MockSessionRepository();
    getActiveCompanyId = MockGetActiveCompanyIdUseCase();
    sessionController = StreamController<UserDataEntity>.broadcast();
    final fixture = UserFactory.makeUserDataEntity();
    session = fixture.copyWith(
      user: fixture.user.copyWith(id: 'u-1', companyId: 'c-1'),
    );
    activeCompanyId = 'c-1';
    when(() => sessionRepository.userData).thenAnswer((_) => session);
    when(
      () => sessionRepository.sessionStream,
    ).thenAnswer((_) => sessionController.stream);
    when(() => getActiveCompanyId()).thenAnswer((_) => activeCompanyId);
    when(
      () => mockInternetClient.connectivityStream,
    ).thenAnswer((_) => connectivityController.stream);
    when(() => mockInternetClient.isConnected).thenReturn(false);

    tracker = OfflineTrackerImpl(
      internetClient: mockInternetClient,
      database: database,
      sessionRepository: sessionRepository,
      getActiveCompanyId: getActiveCompanyId,
    );
  });

  tearDown(() async {
    tracker.dispose();
    await sessionController.close();
    await connectivityController.close();
    await database.close();
  });

  Future<void> cacheParameters(
    String companyId, {
    int limit = 3,
    int hours = 1,
  }) async {
    await database
        .into(database.companyParameters)
        .insertOnConflictUpdate(
          CompanyParametersCompanion(
            id: Value('params-$companyId'),
            companyId: Value(companyId),
            maxOfflinePendingRequests: Value(limit),
            maxOfflineDurationHours: Value(hours),
            offlineAlertThrottleFrequency: const Value(2),
          ),
        );
  }

  Future<void> enqueue(
    String id, {
    String companyId = 'c-1',
    String userId = 'u-1',
    String status = 'pending',
  }) async {
    await database
        .into(database.syncAuditLogs)
        .insert(
          SyncAuditLogsCompanion(
            id: Value(id),
            companyId: Value(companyId),
            userProfileId: Value(userId),
            entityType: const Value('work_order'),
            entityId: Value('wo-$id'),
            operation: const Value('create'),
            payload: const Value('{}'),
            status: Value(status),
          ),
        );
  }

  group('OfflineTracker', () {
    test(
      'uses active company limits with three cached companies and scopes the queue to its user',
      () async {
        await cacheParameters('c-2', limit: 1);
        await cacheParameters('c-1');
        await cacheParameters('c-3', limit: 1);
        await enqueue('1');
        await enqueue('2', status: 'syncing');
        await enqueue('other-company', companyId: 'c-2');
        await enqueue('other-user', userId: 'u-2');
        await enqueue('completed', status: 'success');
        tracker.init();
        await pumpEventQueue();

        expect(tracker.offlineMutationCount, 2);
        expect(tracker.hasBreachedRequests, isFalse);

        final events = <OfflineAdvisoryEvent>[];
        final subscription = tracker.alertStream.listen(events.add);
        await enqueue('3');
        await pumpEventQueue();
        expect(events, hasLength(1));
        expect(events.single.pendingMutationCount, 3);
        await enqueue('4');
        await pumpEventQueue();
        expect(events, hasLength(1));
        await enqueue('5');
        await pumpEventQueue();
        expect(events, hasLength(2));
        await subscription.cancel();
      },
    );

    test('loads company limits before evaluating the existing queue', () async {
      await cacheParameters('c-1', limit: 1);
      await enqueue('1');
      final events = <OfflineAdvisoryEvent>[];
      final subscription = tracker.alertStream.listen(events.add);
      tracker
        ..init()
        ..init();
      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(tracker.hasBreachedRequests, isTrue);
      await subscription.cancel();
    });

    test(
      'switches company limits and pending counts with the session',
      () async {
        await cacheParameters('c-1', limit: 1);
        await cacheParameters('c-2');
        await enqueue('1');
        await enqueue('2', companyId: 'c-2');
        await enqueue('3', companyId: 'c-2');
        tracker.init();
        await pumpEventQueue();
        expect(tracker.hasBreachedRequests, isTrue);

        activeCompanyId = 'c-2';
        sessionController.add(session);
        await pumpEventQueue();
        expect(tracker.offlineMutationCount, 2);
        expect(tracker.hasBreachedRequests, isFalse);
        expect(tracker.lastAlertMutationCount, 0);

        await cacheParameters('c-1', limit: 1, hours: 0);
        await enqueue('old-company');
        await pumpEventQueue();
        expect(tracker.offlineMutationCount, 2);
        expect(tracker.hasBreachedDuration, isFalse);
        await cacheParameters('c-2', limit: 2);
        await pumpEventQueue();
        expect(tracker.hasBreachedRequests, isTrue);
      },
    );

    test(
      'observes a persisted company selection without a session event',
      () async {
        await cacheParameters('c-1', limit: 1);
        await cacheParameters('c-2');
        await enqueue('1');
        tracker.init();
        await pumpEventQueue();
        activeCompanyId = 'c-2';
        await database
            .into(database.appSettings)
            .insert(
              const AppSettingsCompanion(
                id: Value(1),
                selectedCompanyId: Value('c-2'),
              ),
            );
        await pumpEventQueue();
        expect(tracker.offlineMutationCount, 0);
        expect(tracker.hasBreachedRequests, isFalse);
      },
    );

    test(
      'restores default limits for deleted and missing company parameters',
      () async {
        await cacheParameters('c-1', limit: 1, hours: 0);
        await enqueue('1');
        tracker.init();
        await pumpEventQueue();
        expect(tracker.hasBreachedRequests, isTrue);
        expect(tracker.hasBreachedDuration, isTrue);

        await (database.update(
          database.companyParameters,
        )..where((row) => row.companyId.equals('c-1'))).write(
          CompanyParametersCompanion(deletedAt: Value(DateTime.now())),
        );
        await pumpEventQueue();
        expect(tracker.hasBreachedRequests, isFalse);
        expect(tracker.hasBreachedDuration, isFalse);

        activeCompanyId = 'uncached';
        sessionController.add(session);
        await enqueue('uncached', companyId: 'uncached');
        await pumpEventQueue();
        expect(tracker.offlineMutationCount, 1);
        expect(tracker.hasBreachedRequests, isFalse);
      },
    );

    test(
      'clears company tracking on logout and does not use cached rows without a company',
      () async {
        await cacheParameters('c-1', limit: 1);
        await enqueue('1');
        tracker.init();
        await pumpEventQueue();
        expect(tracker.offlineMutationCount, 1);

        session = session.copyWith(accessToken: '');
        sessionController.add(session);
        await pumpEventQueue();
        expect(tracker.offlineMutationCount, 0);
        expect(tracker.hasBreachedRequests, isFalse);

        session = session.copyWith(accessToken: 'test-session');
        activeCompanyId = '';
        sessionController.add(session);
        await enqueue('2');
        await pumpEventQueue();
        expect(tracker.offlineMutationCount, 0);
        expect(tracker.hasBreachedRequests, isFalse);
      },
    );

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

    test(
      'dynamically updates limits when company parameters change in database',
      () async {
        activeCompanyId = 'c-custom';
        when(() => mockInternetClient.isConnected).thenReturn(false);
        tracker.init();

        // Insert company & custom parameters in DB: max 3 pending requests
        await database
            .into(database.companies)
            .insert(
              CompaniesCompanion(
                id: const Value('c-custom'),
                name: const Value('Custom Co'),
                isActive: const Value(true),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
        await database
            .into(database.companyParameters)
            .insert(
              CompanyParametersCompanion(
                id: const Value('cp-1'),
                companyId: const Value('c-custom'),
                maxOfflinePendingRequests: const Value(3),
                maxOfflineDurationHours: const Value(1),
                offlineAlertThrottleFrequency: const Value(2),
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
            );
        await pumpEventQueue();

        final events = <OfflineAdvisoryEvent>[];
        final sub = tracker.alertStream.listen(events.add);

        // Insert 2 items: below custom limit (3)
        for (var i = 1; i <= 2; i++) {
          await database
              .into(database.syncAuditLogs)
              .insert(
                SyncAuditLogsCompanion(
                  id: Value('custom-$i'),
                  companyId: const Value('c-custom'),
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
        expect(events, isEmpty);

        // Insert 3rd item: hits custom limit of 3
        await database
            .into(database.syncAuditLogs)
            .insert(
              const SyncAuditLogsCompanion(
                id: Value('custom-3'),
                companyId: Value('c-custom'),
                userProfileId: Value('u-1'),
                entityType: Value('work_order'),
                entityId: Value('wo-3'),
                operation: Value('create'),
                payload: Value('{}'),
                status: Value('pending'),
              ),
            );
        await pumpEventQueue();

        expect(events.length, equals(1));
        expect(events.first.hasBreachedRequests, isTrue);

        await sub.cancel();
      },
    );
  });
}
