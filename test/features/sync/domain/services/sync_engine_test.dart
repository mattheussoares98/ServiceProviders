import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/sync/domain/services/sync_engine.dart';
import 'package:o_jogo_da_obra/features/sync/domain/use_cases/get_pending_sync_count_use_case.dart';
import 'package:o_jogo_da_obra/features/sync/domain/use_cases/process_sync_queue_use_case.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

class MockProcessSyncQueueUseCase extends Mock
    implements ProcessSyncQueueUseCase {}

class MockGetPendingSyncCountUseCase extends Mock
    implements GetPendingSyncCountUseCase {}

void main() {
  late MockInternetClient mockInternet;
  late MockProcessSyncQueueUseCase mockProcessSyncQueueUseCase;
  late MockGetPendingSyncCountUseCase mockGetPendingSyncCountUseCase;
  late MockWorkOrdersRepository mockWorkOrdersRepository;
  late MockSessionRepository mockSessionRepository;
  late MockSyncRepository mockSyncRepository;
  late SyncEngineImpl syncEngine;

  setUp(() {
    mockInternet = MockInternetClient();
    mockProcessSyncQueueUseCase = MockProcessSyncQueueUseCase();
    mockGetPendingSyncCountUseCase = MockGetPendingSyncCountUseCase();
    mockWorkOrdersRepository = MockWorkOrdersRepository();
    mockSessionRepository = MockSessionRepository();
    mockSyncRepository = MockSyncRepository();

    syncEngine = SyncEngineImpl(
      internetClient: mockInternet,
      processSyncQueueUseCase: mockProcessSyncQueueUseCase,
      getPendingSyncCountUseCase: mockGetPendingSyncCountUseCase,
      workOrdersRepository: mockWorkOrdersRepository,
      sessionRepository: mockSessionRepository,
      syncRepository: mockSyncRepository,
    );
  });

  tearDown(() {
    syncEngine.dispose();
  });

  group('SyncEngineImpl', () {
    test(
      'should process queue, trigger delta sync, and emit onSyncCompleted in internal mode when connected and queue clear',
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
          () => mockGetPendingSyncCountUseCase.call(),
        ).thenAnswer((_) async => const SuccessState(data: 0));
        when(
          () => mockWorkOrdersRepository.syncWorkOrders('company-123'),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final events = <void>[];
        final sub = syncEngine.onSyncCompleted.listen(events.add);

        final processed = await syncEngine.processQueue();
        await pumpEventQueue();

        expect(processed, equals(2));
        expect(events.length, equals(1));
        verify(() => mockProcessSyncQueueUseCase.call()).called(1);
        verify(
          () => mockWorkOrdersRepository.syncWorkOrders('company-123'),
        ).called(1);

        await sub.cancel();
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
          () => mockGetPendingSyncCountUseCase.call(),
        ).thenAnswer((_) async => const SuccessState(data: 0));
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

    test('should stream dead-letter items from sync repository', () async {
      final tEntity = EntityFactory.makeSyncQueueItemEntity();
      when(
        () => mockSyncRepository.watchDeadLetterItemsForEntity(any()),
      ).thenAnswer((_) => Stream.value([tEntity]));

      final stream = syncEngine.watchDeadLetterItemsForEntity('wo-123');
      final result = await stream.first;

      expect(result.length, equals(1));
      expect(result.first.id, equals(tEntity.id));
      verify(
        () => mockSyncRepository.watchDeadLetterItemsForEntity('wo-123'),
      ).called(1);
    });

    test('should call retryDeadLetterForEntity and processQueue on retryEntity', () async {
      when(() => mockInternet.isConnected).thenReturn(true);
      when(
        () => mockSessionRepository.getSelectedMode(),
      ).thenReturn(AppMode.internal.name);
      when(
        () => mockSessionRepository.getSelectedCompanyId(),
      ).thenReturn('company-1');
      when(
        () => mockSyncRepository.retryDeadLetterForEntity(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));
      when(
        () => mockProcessSyncQueueUseCase.call(),
      ).thenAnswer((_) async => const SuccessState(data: 1));
      when(
        () => mockGetPendingSyncCountUseCase.call(),
      ).thenAnswer((_) async => const SuccessState(data: 0));
      when(
        () => mockWorkOrdersRepository.syncWorkOrders('company-1'),
      ).thenAnswer((_) async => const SuccessState(data: true));

      await syncEngine.retryEntity('wo-123');

      verify(
        () => mockSyncRepository.retryDeadLetterForEntity('wo-123'),
      ).called(1);
      verify(() => mockProcessSyncQueueUseCase.call()).called(1);
    });
  });
}
