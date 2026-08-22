import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/core/constants/offline_limits.dart';
import '../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late StreamController<InternetStatus> connectivityController;
  late OfflineTrackerImpl tracker;

  setUp(() {
    mockInternetClient = MockInternetClient();
    connectivityController = StreamController<InternetStatus>.broadcast();
    when(
      () => mockInternetClient.connectivityStream,
    ).thenAnswer((_) => connectivityController.stream);
    when(() => mockInternetClient.isConnected).thenReturn(false);

    tracker = OfflineTrackerImpl(internetClient: mockInternetClient);
  });

  tearDown(() {
    tracker.dispose();
    connectivityController.close();
  });

  group('OfflineTracker', () {
    test('does nothing when online', () {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      expect(tracker.recordOfflineAction(), isFalse);
      expect(tracker.offlineMutationCount, equals(0));
      expect(tracker.checkStartupOrResumeStatus(), isFalse);
    });

    test(
      'tracks offline actions and triggers alert at limit and every 3 actions thereafter',
      () {
        when(() => mockInternetClient.isConnected).thenReturn(false);

        // Actions 1 to 9 (below kMaxOfflinePendingRequests = 10)
        for (var i = 1; i < kMaxOfflinePendingRequests; i++) {
          final shouldAlert = tracker.recordOfflineAction();
          expect(
            shouldAlert,
            isFalse,
            reason: 'Action $i should not trigger alert',
          );
          expect(tracker.offlineMutationCount, equals(i));
        }

        // Action 10 (hits limit)
        final alertAtLimit = tracker.recordOfflineAction();
        expect(alertAtLimit, isTrue, reason: 'Action 10 should trigger alert');
        expect(
          tracker.offlineMutationCount,
          equals(kMaxOfflinePendingRequests),
        );
        expect(tracker.lastAlertMutationCount, equals(10));

        // Action 11 (throttled)
        expect(tracker.recordOfflineAction(), isFalse);
        // Action 12 (throttled)
        expect(tracker.recordOfflineAction(), isFalse);

        // Action 13 (10 + 3 => throttled interval reached)
        final alertAt13 = tracker.recordOfflineAction();
        expect(alertAt13, isTrue, reason: 'Action 13 should trigger alert');
        expect(tracker.lastAlertMutationCount, equals(13));
      },
    );

    test(
      'checkStartupOrResumeStatus returns true when threshold is breached',
      () {
        when(() => mockInternetClient.isConnected).thenReturn(false);

        // Under limit
        expect(tracker.checkStartupOrResumeStatus(), isFalse);

        // Breach request limit
        for (var i = 0; i < kMaxOfflinePendingRequests; i++) {
          tracker.recordOfflineAction();
        }

        expect(tracker.checkStartupOrResumeStatus(), isTrue);
      },
    );

    test('emits OfflineAdvisoryEvent to alertStream when alert triggers', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final events = <OfflineAdvisoryEvent>[];
      final sub = tracker.alertStream.listen(events.add);

      for (var i = 0; i < kMaxOfflinePendingRequests; i++) {
        tracker.recordOfflineAction();
      }

      await pumpEventQueue();
      expect(events.length, equals(1));
      expect(events.first.trigger, equals(OfflineAdvisoryTrigger.action));
      expect(events.first.hasBreachedRequests, isTrue);

      await sub.cancel();
    });

    test('resets counters when reset is called or internet reconnects', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      tracker.init();

      for (var i = 0; i < 5; i++) {
        tracker.recordOfflineAction();
      }
      expect(tracker.offlineMutationCount, equals(5));

      // Reconnect
      connectivityController.add(InternetStatus.connected);
      await pumpEventQueue();

      expect(tracker.offlineMutationCount, equals(0));
      expect(tracker.offlineSince, isNull);
    });
  });
}
