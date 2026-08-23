import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/sync/domain/services/sync_engine.dart';
import 'package:o_jogo_da_obra/features/sync/domain/use_cases/process_sync_queue_use_case.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

class MockProcessSyncQueueUseCase extends Mock
    implements ProcessSyncQueueUseCase {}

void main() {
  late MockInternetClient mockInternet;
  late MockProcessSyncQueueUseCase mockProcessSyncQueueUseCase;
  late MockWorkOrdersRepository mockWorkOrdersRepository;
  late MockSessionRepository mockSessionRepository;
  late SyncEngineImpl syncEngine;

  setUp(() {
    mockInternet = MockInternetClient();
    mockProcessSyncQueueUseCase = MockProcessSyncQueueUseCase();
    mockWorkOrdersRepository = MockWorkOrdersRepository();
    mockSessionRepository = MockSessionRepository();

    syncEngine = SyncEngineImpl(
      internetClient: mockInternet,
      processSyncQueueUseCase: mockProcessSyncQueueUseCase,
      workOrdersRepository: mockWorkOrdersRepository,
      sessionRepository: mockSessionRepository,
    );
  });

  group('SyncEngineImpl', () {
    test(
      'should process queue and trigger delta sync in internal mode when connected',
      () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        when(
          () => mockSessionRepository.getSelectedMode(),
        ).thenReturn(AppMode.internal.name);
        when(
          () => mockSessionRepository.getSelectedCompanyId(),
        ).thenReturn('company-123');
        when(
          () => mockProcessSyncQueueUseCase.call(),
        ).thenAnswer((_) async => const SuccessState(data: 2));
        when(
          () => mockWorkOrdersRepository.syncWorkOrders('company-123'),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final processed = await syncEngine.processQueue();

        expect(processed, equals(2));
        verify(() => mockProcessSyncQueueUseCase.call()).called(1);
        verify(
          () => mockWorkOrdersRepository.syncWorkOrders('company-123'),
        ).called(1);
      },
    );

    test('should do nothing in provider mode', () async {
      when(() => mockInternet.isConnected).thenReturn(true);
      when(
        () => mockSessionRepository.getSelectedMode(),
      ).thenReturn(AppMode.provider.name);

      final processed = await syncEngine.processQueue();

      expect(processed, equals(0));
      verifyNever(() => mockProcessSyncQueueUseCase.call());
    });

    test(
      'should trigger processQueue on internet status change to connected',
      () async {
        final controller = StreamController<InternetStatus>.broadcast();
        when(
          () => mockInternet.connectivityStream,
        ).thenAnswer((_) => controller.stream);
        when(() => mockInternet.isConnected).thenReturn(false);
        when(
          () => mockSessionRepository.getSelectedMode(),
        ).thenReturn(AppMode.internal.name);
        when(
          () => mockSessionRepository.getSelectedCompanyId(),
        ).thenReturn('c-1');
        when(
          () => mockProcessSyncQueueUseCase.call(),
        ).thenAnswer((_) async => const SuccessState(data: 1));
        when(
          () => mockWorkOrdersRepository.syncWorkOrders('c-1'),
        ).thenAnswer((_) async => const SuccessState(data: true));

        syncEngine.init();

        when(() => mockInternet.isConnected).thenReturn(true);
        controller.add(InternetStatus.connected);

        await Future<void>.delayed(const Duration(milliseconds: 50));

        verify(() => mockProcessSyncQueueUseCase.call()).called(1);
        await controller.close();
      },
    );
  });
}
