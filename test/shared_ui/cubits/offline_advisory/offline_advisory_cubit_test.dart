import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_state.dart';

import '../../../../testing/mocks/client_mocks.dart';
import '../../../../testing/mocks/use_case_mocks.dart';

void main() {
  late MockOfflineTracker mockOfflineTracker;
  late MockInternetClient mockInternetClient;
  late MockGetSelectedModeUseCase mockGetSelectedMode;
  late MockNavigationClient mockNavigationClient;
  late StreamController<OfflineAdvisoryEvent> alertStreamController;
  late StreamController<InternetStatus> connectivityStreamController;

  setUpAll(() {
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);
  });

  tearDownAll(() async {
    await GetIt.I.reset();
  });

  setUp(() {
    mockOfflineTracker = MockOfflineTracker();
    mockInternetClient = MockInternetClient();
    mockGetSelectedMode = MockGetSelectedModeUseCase();
    alertStreamController = StreamController<OfflineAdvisoryEvent>.broadcast();
    connectivityStreamController = StreamController<InternetStatus>.broadcast();

    when(
      () => mockOfflineTracker.alertStream,
    ).thenAnswer((_) => alertStreamController.stream);
    when(
      () => mockOfflineTracker.checkStartupOrResumeStatus(),
    ).thenReturn(false);

    when(
      () => mockInternetClient.connectivityStream,
    ).thenAnswer((_) => connectivityStreamController.stream);
    when(() => mockInternetClient.isConnected).thenReturn(true);
    when(
      () => mockInternetClient.checkConnection(),
    ).thenAnswer((_) async => true);

    when(() => mockGetSelectedMode.call()).thenReturn(AppMode.internal.name);
  });

  tearDown(() {
    alertStreamController.close();
    connectivityStreamController.close();
  });

  const tEvent = OfflineAdvisoryEvent(
    trigger: OfflineAdvisoryTrigger.action,
    offlineDuration: Duration(hours: 2),
    pendingMutationCount: 10,
    hasBreachedDuration: true,
    hasBreachedRequests: true,
  );

  OfflineAdvisoryCubit createCubit() => OfflineAdvisoryCubit(
    offlineTracker: mockOfflineTracker,
    internetClient: mockInternetClient,
    getSelectedMode: mockGetSelectedMode,
  );

  group('OfflineAdvisoryCubit', () {
    test('initial state has no advisoryEvent and is not blocked', () {
      final cubit = createCubit();
      expect(cubit.state.shouldShowDialog, isFalse);
      expect(cubit.state.isProviderBlocked, isFalse);
      cubit.close();
    });

    blocTest<OfflineAdvisoryCubit, OfflineAdvisoryState>(
      'emits state with advisoryEvent when alert is emitted from tracker',
      build: createCubit,
      act: (cubit) => alertStreamController.add(tEvent),
      expect: () => [
        isA<OfflineAdvisoryState>()
            .having((s) => s.status, 'status', DataStatus.loaded)
            .having((s) => s.advisoryEvent, 'advisoryEvent', tEvent)
            .having((s) => s.shouldShowDialog, 'shouldShowDialog', isTrue),
      ],
    );

    blocTest<OfflineAdvisoryCubit, OfflineAdvisoryState>(
      'dismissAlert clears the active advisoryEvent',
      build: createCubit,
      seed: () => const OfflineAdvisoryState(advisoryEvent: tEvent),
      act: (cubit) => cubit.dismissAlert(),
      expect: () => [
        isA<OfflineAdvisoryState>()
            .having((s) => s.advisoryEvent, 'advisoryEvent', isNull)
            .having((s) => s.shouldShowDialog, 'shouldShowDialog', isFalse),
      ],
    );

    test(
      'checkStartupOrResume delegates to offlineTracker and checks mode',
      () async {
        when(
          () => mockOfflineTracker.checkStartupOrResumeStatus(),
        ).thenReturn(true);
        final cubit = createCubit()..checkStartupOrResume();
        verify(() => mockOfflineTracker.checkStartupOrResumeStatus()).called(1);
        expect(cubit.state.isProviderBlocked, isFalse);
        await cubit.close();
      },
    );

    group('Provider Mode blocking', () {
      test('does not block in internal mode even if offline', () {
        when(
          () => mockGetSelectedMode.call(),
        ).thenReturn(AppMode.internal.name);
        when(() => mockInternetClient.isConnected).thenReturn(false);

        final cubit = createCubit()..checkProviderConnectivity();

        expect(cubit.state.isProviderBlocked, isFalse);
        cubit.close();
      });

      test('does not block in provider mode if online', () {
        when(
          () => mockGetSelectedMode.call(),
        ).thenReturn(AppMode.provider.name);
        when(() => mockInternetClient.isConnected).thenReturn(true);

        final cubit = createCubit()..checkProviderConnectivity();

        expect(cubit.state.isProviderBlocked, isFalse);
        cubit.close();
      });

      test('blocks when in provider mode and offline', () {
        when(
          () => mockGetSelectedMode.call(),
        ).thenReturn(AppMode.provider.name);
        when(() => mockInternetClient.isConnected).thenReturn(false);

        final cubit = createCubit()..checkProviderConnectivity();

        expect(cubit.state.isProviderBlocked, isTrue);
        cubit.close();
      });

      blocTest<OfflineAdvisoryCubit, OfflineAdvisoryState>(
        'emits isProviderBlocked true when connection drops in provider mode',
        build: () {
          when(
            () => mockGetSelectedMode.call(),
          ).thenReturn(AppMode.provider.name);
          when(() => mockInternetClient.isConnected).thenReturn(false);
          return createCubit();
        },
        act: (cubit) =>
            connectivityStreamController.add(InternetStatus.disconnected),
        expect: () => [
          isA<OfflineAdvisoryState>().having(
            (s) => s.isProviderBlocked,
            'isProviderBlocked',
            isTrue,
          ),
        ],
      );

      blocTest<OfflineAdvisoryCubit, OfflineAdvisoryState>(
        'unblocks when connection is restored in provider mode',
        build: () {
          when(
            () => mockGetSelectedMode.call(),
          ).thenReturn(AppMode.provider.name);
          when(() => mockInternetClient.isConnected).thenReturn(true);
          return createCubit();
        },
        seed: () => const OfflineAdvisoryState(isProviderBlocked: true),
        act: (cubit) =>
            connectivityStreamController.add(InternetStatus.connected),
        expect: () => [
          isA<OfflineAdvisoryState>().having(
            (s) => s.isProviderBlocked,
            'isProviderBlocked',
            isFalse,
          ),
        ],
      );

      test(
        'retryConnection re-evaluates connectivity and updates state',
        () async {
          when(
            () => mockGetSelectedMode.call(),
          ).thenReturn(AppMode.provider.name);
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(() => mockInternetClient.checkConnection()).thenAnswer((
            _,
          ) async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            return true;
          });

          final cubit = createCubit()..checkProviderConnectivity();
          expect(cubit.state.isProviderBlocked, isTrue);

          final result = await cubit.retryConnection();

          expect(result, isTrue);
          expect(cubit.state.isProviderBlocked, isFalse);
          await cubit.close();
        },
      );
    });
  });
}
