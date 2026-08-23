import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/use_cases/enqueue_sync_item_use_case.dart';
import 'package:o_jogo_da_obra/features/sync/domain/use_cases/get_pending_sync_count_use_case.dart';
import 'package:o_jogo_da_obra/features/sync/domain/use_cases/process_sync_queue_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockSyncRepository mockSyncRepository;
  late MockWorkOrdersRemoteDataSource mockWorkOrdersRemoteDataSource;
  late MockWorkOrderObservationsRemoteDataSource mockObservationsRemoteDataSource;
  late MockPauseRemoteDataSource mockPauseRemoteDataSource;
  late MockInternetClient mockInternet;

  late EnqueueSyncItemUseCase enqueueUseCase;
  late GetPendingSyncCountUseCase getPendingCountUseCase;
  late ProcessSyncQueueUseCase processSyncQueueUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeSyncQueueItemEntity());
    registerFallbackValue(EntityFactory.makeSyncErrorEntity());
    registerFallbackValue(
      WorkOrderModel.fromEntity(EntityFactory.makeWorkOrderEntity()),
    );
    registerFallbackValue(
      WorkOrderObservationModel.fromEntity(
        EntityFactory.makeWorkOrderObservationEntity(),
      ),
    );
  });

  setUp(() {
    mockSyncRepository = MockSyncRepository();
    mockWorkOrdersRemoteDataSource = MockWorkOrdersRemoteDataSource();
    mockObservationsRemoteDataSource =
        MockWorkOrderObservationsRemoteDataSource();
    mockPauseRemoteDataSource = MockPauseRemoteDataSource();
    mockInternet = MockInternetClient();

    enqueueUseCase = EnqueueSyncItemUseCase(repository: mockSyncRepository);
    getPendingCountUseCase = GetPendingSyncCountUseCase(
      repository: mockSyncRepository,
    );
    processSyncQueueUseCase = ProcessSyncQueueUseCase(
      syncRepository: mockSyncRepository,
      workOrdersRemoteDataSource: mockWorkOrdersRemoteDataSource,
      observationsRemoteDataSource: mockObservationsRemoteDataSource,
      pauseRemoteDataSource: mockPauseRemoteDataSource,
      internet: mockInternet,
    );
  });

  final tQueueItem = EntityFactory.makeSyncQueueItemEntity();

  group('Sync UseCases', () {
    group('EnqueueSyncItemUseCase', () {
      test('should delegate to syncRepository.enqueue', () async {
        when(
          () => mockSyncRepository.enqueue(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await enqueueUseCase(tQueueItem);

        expect(result, isA<SuccessState<bool>>());
        verify(() => mockSyncRepository.enqueue(tQueueItem)).called(1);
      });
    });

    group('GetPendingSyncCountUseCase', () {
      test('should delegate to syncRepository.getPendingCount', () async {
        when(
          () => mockSyncRepository.getPendingCount(),
        ).thenAnswer((_) async => const SuccessState(data: 5));

        final result = await getPendingCountUseCase();

        expect(result, isA<SuccessState<int>>());
        expect(result.data, equals(5));
        verify(() => mockSyncRepository.getPendingCount()).called(1);
      });
    });

    group('ProcessSyncQueueUseCase', () {
      test('should return FailureState.noInternet when offline', () async {
        when(() => mockInternet.isConnected).thenReturn(false);

        final result = await processSyncQueueUseCase();

        expect(result, isA<FailureState<int>>());
        verifyNever(() => mockSyncRepository.getPendingItems());
      });

      test('should process work order create and remove item from queue on success', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        final tWoEntity = EntityFactory.makeWorkOrderEntity();
        final tItem = tQueueItem.copyWith(
          entityType: SyncEntityType.workOrder,
          operation: SyncOperationType.create,
          payload: '{"id": "${tWoEntity.id}", "company_id": "${tWoEntity.companyId}", "location_id": "${tWoEntity.locationId}", "title": "Test", "type": "corrective", "priority": "medium", "status": "open", "created_at": "2026-08-23T10:00:00.000Z", "updated_at": "2026-08-23T10:00:00.000Z"}',
        );

        when(
          () => mockSyncRepository.getPendingItems(),
        ).thenAnswer((_) async => SuccessState(data: [tItem]));
        when(
          () => mockSyncRepository.markItemSyncing(tItem.id),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockWorkOrdersRemoteDataSource.createWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockSyncRepository.removeQueueItem(tItem.id),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await processSyncQueueUseCase();

        expect(result, isA<SuccessState<int>>());
        expect(result.data, equals(1));
        verify(() => mockWorkOrdersRemoteDataSource.createWorkOrder(any())).called(1);
        verify(() => mockSyncRepository.removeQueueItem(tItem.id)).called(1);
      });

      test('should mark deadLetter, cascade cancel, and report error telemetry when permanent remote failure occurs', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        final tItem = tQueueItem.copyWith(
          entityType: SyncEntityType.workOrder,
          operation: SyncOperationType.create,
          payload: '{"id": "wo-1", "company_id": "c-1", "location_id": "l-1", "title": "Test", "type": "corrective", "priority": "medium", "status": "open", "created_at": "2026-08-23T10:00:00.000Z", "updated_at": "2026-08-23T10:00:00.000Z"}',
        );

        when(
          () => mockSyncRepository.getPendingItems(),
        ).thenAnswer((_) async => SuccessState(data: [tItem]));
        when(
          () => mockSyncRepository.markItemSyncing(tItem.id),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockWorkOrdersRemoteDataSource.createWorkOrder(any()),
        ).thenAnswer(
          (_) async => FailureState(
            message: '400 Bad Request: Constraint failed',
            statusCode: 400,
          ),
        );
        when(
          () => mockSyncRepository.markItemDeadLetter(any(), any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockSyncRepository.cancelPendingForEntity(any(), any()),
        ).thenAnswer((_) async => SuccessState.nil);
        when(
          () => mockSyncRepository.reportSyncError(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await processSyncQueueUseCase();

        expect(result, isA<SuccessState<int>>());
        expect(result.data, equals(0));
        verify(() => mockSyncRepository.markItemDeadLetter(tItem.id, any())).called(1);
        verify(
          () => mockSyncRepository.cancelPendingForEntity(
            tItem.entityId,
            any(),
          ),
        ).called(1);
        verify(() => mockSyncRepository.reportSyncError(any())).called(1);
        verifyNever(() => mockSyncRepository.removeQueueItem(tItem.id));
      });

      test('should mark failed when transient server failure occurs and attempts < 3', () async {
        when(() => mockInternet.isConnected).thenReturn(true);
        final tItem = tQueueItem.copyWith(
          attempts: 0,
          entityType: SyncEntityType.workOrder,
          operation: SyncOperationType.update,
          payload: '{"id": "wo-1", "title": "Updated"}',
        );

        when(
          () => mockSyncRepository.getPendingItems(),
        ).thenAnswer((_) async => SuccessState(data: [tItem]));
        when(
          () => mockSyncRepository.markItemSyncing(tItem.id),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockWorkOrdersRemoteDataSource.updateWorkOrder(any()),
        ).thenAnswer(
          (_) async => FailureState(
            message: '503 Service Unavailable',
            statusCode: 503,
          ),
        );
        when(
          () => mockSyncRepository.markItemFailed(any(), any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockSyncRepository.reportSyncError(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await processSyncQueueUseCase();

        expect(result, isA<SuccessState<int>>());
        expect(result.data, equals(0));
        verify(() => mockSyncRepository.markItemFailed(tItem.id, any())).called(1);
        verifyNever(() => mockSyncRepository.markItemDeadLetter(any(), any()));
      });
    });
  });
}
