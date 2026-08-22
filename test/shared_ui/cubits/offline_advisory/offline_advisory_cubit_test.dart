import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_state.dart';

import '../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockOfflineTracker mockOfflineTracker;
  late MockNavigationClient mockNavigationClient;
  late StreamController<OfflineAdvisoryEvent> alertStreamController;

  setUpAll(() {
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  setUp(() {
    mockOfflineTracker = MockOfflineTracker();
    alertStreamController = StreamController<OfflineAdvisoryEvent>.broadcast();
    when(
      () => mockOfflineTracker.alertStream,
    ).thenAnswer((_) => alertStreamController.stream);
    when(
      () => mockOfflineTracker.checkStartupOrResumeStatus(),
    ).thenReturn(false);
  });

  tearDown(() {
    alertStreamController.close();
  });

  const tEvent = OfflineAdvisoryEvent(
    trigger: OfflineAdvisoryTrigger.action,
    offlineDuration: Duration(hours: 2),
    pendingMutationCount: 10,
    hasBreachedDuration: true,
    hasBreachedRequests: true,
  );

  group('OfflineAdvisoryCubit', () {
    test('initial state has no advisoryEvent', () {
      final cubit = OfflineAdvisoryCubit(offlineTracker: mockOfflineTracker);
      expect(cubit.state.shouldShowDialog, isFalse);
      cubit.close();
    });

    blocTest<OfflineAdvisoryCubit, OfflineAdvisoryState>(
      'emits state with advisoryEvent when alert is emitted from tracker',
      build: () => OfflineAdvisoryCubit(offlineTracker: mockOfflineTracker),
      act: (cubit) => alertStreamController.add(tEvent),
      expect: () => [
        isA<OfflineAdvisoryState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.advisoryEvent, 'advisoryEvent', tEvent)
            .having((s) => s.shouldShowDialog, 'shouldShowDialog', isTrue),
      ],
    );

    blocTest<OfflineAdvisoryCubit, OfflineAdvisoryState>(
      'dismissAlert clears the active advisoryEvent',
      build: () => OfflineAdvisoryCubit(offlineTracker: mockOfflineTracker),
      seed: () => const OfflineAdvisoryState(advisoryEvent: tEvent),
      act: (cubit) => cubit.dismissAlert(),
      expect: () => [
        isA<OfflineAdvisoryState>()
            .having((s) => s.advisoryEvent, 'advisoryEvent', isNull)
            .having((s) => s.shouldShowDialog, 'shouldShowDialog', isFalse),
      ],
    );

    test('checkStartupOrResume delegates to offlineTracker', () async {
      when(
        () => mockOfflineTracker.checkStartupOrResumeStatus(),
      ).thenReturn(true);
      final cubit = OfflineAdvisoryCubit(offlineTracker: mockOfflineTracker)
        ..checkStartupOrResume();
      verify(() => mockOfflineTracker.checkStartupOrResumeStatus()).called(1);
      await cubit.close();
    });
  });
}
