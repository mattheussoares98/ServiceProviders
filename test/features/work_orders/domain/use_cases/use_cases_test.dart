import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/calculate_work_order_kpis_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_reasons_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_change_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/sync_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_work_orders_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/kpi_period.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockWorkOrdersRepository mockRepository;
  late MockPauseRepository mockPauseRepository;

  late CreateWorkOrderChangeRequestUseCase createWorkOrderChangeRequestUseCase;
  late CreateWorkOrderUseCase createWorkOrderUseCase;
  late DeleteWorkOrderUseCase deleteWorkOrderUseCase;
  late GetWorkOrderChangeRequestsUseCase getWorkOrderChangeRequestsUseCase;
  late GetWorkOrderHistoryUseCase getWorkOrderHistoryUseCase;
  late GetWorkOrdersUseCase getWorkOrdersUseCase;
  late GetWorkOrderByIdUseCase getWorkOrderByIdUseCase;
  late ReviewWorkOrderChangeRequestUseCase reviewWorkOrderChangeRequestUseCase;
  late UpdateWorkOrderUseCase updateWorkOrderUseCase;
  late SyncWorkOrdersUseCase syncWorkOrdersUseCase;
  late WatchWorkOrdersRealtimeUseCase watchWorkOrdersRealtimeUseCase;

  late GetPauseReasonsUseCase getPauseReasonsUseCase;
  late GetPauseRequestsUseCase getPauseRequestsUseCase;
  late RequestPauseUseCase requestPauseUseCase;
  late ReviewPauseUseCase reviewPauseUseCase;
  late CancelPauseUseCase cancelPauseUseCase;
  late RequestCompletionUseCase requestCompletionUseCase;
  late ReviewCompletionUseCase reviewCompletionUseCase;
  late CalculateWorkOrderKpisUseCase calculateWorkOrderKpisUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeWorkOrderChangeRequestEntity());
    registerFallbackValue(EntityFactory.makeWorkOrderEntity());
    registerFallbackValue(ChangeRequestStatus.approved);
    registerFallbackValue(const WorkOrderFilter());
    registerFallbackValue(EntityFactory.makeServiceProviderCompanyEntity());
    registerFallbackValue(EntityFactory.makeServiceProviderProfileEntity());
    registerFallbackValue(EntityFactory.makePauseReasonEntity());
    registerFallbackValue(
      const GetPauseRequestsParams(workOrderId: 'fallback-wo-id'),
    );
    registerFallbackValue(EntityFactory.makePauseRequestEntity());
    registerFallbackValue(PauseRequestStatus.pending);
    registerFallbackValue(
      ReviewPauseParams(
        id: faker.guid.guid(),
        workOrderId: faker.guid.guid(),
        status: PauseRequestStatus.approved,
        reviewedById: faker.guid.guid(),
      ),
    );
    registerFallbackValue(
      ReviewCompletionParams(
        id: faker.guid.guid(),
        workOrderId: faker.guid.guid(),
        status: PauseRequestStatus.approved,
        reviewedById: faker.guid.guid(),
      ),
    );
    registerFallbackValue(
      CancelPauseParams(
        id: faker.guid.guid(),
        workOrderId: faker.guid.guid(),
        resumedAt: DateTime.now(),
        resumedById: faker.guid.guid(),
      ),
    );
  });

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    mockPauseRepository = MockPauseRepository();

    createWorkOrderChangeRequestUseCase = CreateWorkOrderChangeRequestUseCase(
      workOrdersRepository: mockRepository,
    );
    createWorkOrderUseCase = CreateWorkOrderUseCase(
      workOrdersRepository: mockRepository,
    );
    deleteWorkOrderUseCase = DeleteWorkOrderUseCase(
      workOrdersRepository: mockRepository,
    );
    getWorkOrderChangeRequestsUseCase = GetWorkOrderChangeRequestsUseCase(
      workOrdersRepository: mockRepository,
    );
    getWorkOrderHistoryUseCase = GetWorkOrderHistoryUseCase(
      workOrdersRepository: mockRepository,
    );
    getWorkOrdersUseCase = GetWorkOrdersUseCase(
      workOrdersRepository: mockRepository,
    );
    getWorkOrderByIdUseCase = GetWorkOrderByIdUseCase(
      workOrdersRepository: mockRepository,
    );
    reviewWorkOrderChangeRequestUseCase = ReviewWorkOrderChangeRequestUseCase(
      workOrdersRepository: mockRepository,
    );
    updateWorkOrderUseCase = UpdateWorkOrderUseCase(
      workOrdersRepository: mockRepository,
    );
    syncWorkOrdersUseCase = SyncWorkOrdersUseCase(
      workOrdersRepository: mockRepository,
    );
    watchWorkOrdersRealtimeUseCase = WatchWorkOrdersRealtimeUseCase(
      workOrdersRepository: mockRepository,
    );
    getPauseReasonsUseCase = GetPauseReasonsUseCase(
      pauseRepository: mockPauseRepository,
    );
    getPauseRequestsUseCase = GetPauseRequestsUseCase(
      pauseRepository: mockPauseRepository,
    );
    requestPauseUseCase = RequestPauseUseCase(
      pauseRepository: mockPauseRepository,
    );
    reviewPauseUseCase = ReviewPauseUseCase(
      pauseRepository: mockPauseRepository,
    );
    cancelPauseUseCase = CancelPauseUseCase(
      pauseRepository: mockPauseRepository,
    );
    requestCompletionUseCase = RequestCompletionUseCase(
      pauseRepository: mockPauseRepository,
    );
    reviewCompletionUseCase = ReviewCompletionUseCase(
      pauseRepository: mockPauseRepository,
    );
    calculateWorkOrderKpisUseCase = const CalculateWorkOrderKpisUseCase();
  });

  group('CreateWorkOrderChangeRequestUseCase', () {
    final tChangeRequest = EntityFactory.makeWorkOrderChangeRequestEntity();

    test('should return true on success', () async {
      // Arrange
      when(
        () => mockRepository.createChangeRequest(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await createWorkOrderChangeRequestUseCase(tChangeRequest);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockRepository.createChangeRequest(tChangeRequest),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.createChangeRequest(any()),
      ).thenAnswer((_) async => FailureState<bool>(message: 'Create failed'));

      // Act
      final result = await createWorkOrderChangeRequestUseCase(tChangeRequest);

      // Assert
      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'Create failed');
      verify(
        () => mockRepository.createChangeRequest(tChangeRequest),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('CreateWorkOrderUseCase', () {
    final tWorkOrder = EntityFactory.makeWorkOrderEntity();

    test('should return true on success', () async {
      // Arrange
      when(
        () => mockRepository.createWorkOrder(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await createWorkOrderUseCase(tWorkOrder);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.createWorkOrder(tWorkOrder)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.createWorkOrder(any()),
      ).thenAnswer((_) async => FailureState<bool>(message: 'Create failed'));

      // Act
      final result = await createWorkOrderUseCase(tWorkOrder);

      // Assert
      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'Create failed');
      verify(() => mockRepository.createWorkOrder(tWorkOrder)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('DeleteWorkOrderUseCase', () {
    final tWorkOrderId = EntityFactory.makeWorkOrderEntity().id;

    test('should return true on success', () async {
      // Arrange
      when(
        () => mockRepository.deleteWorkOrder(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await deleteWorkOrderUseCase(tWorkOrderId);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.deleteWorkOrder(tWorkOrderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.deleteWorkOrder(any()),
      ).thenAnswer((_) async => FailureState<bool>(message: 'Delete failed'));

      // Act
      final result = await deleteWorkOrderUseCase(tWorkOrderId);

      // Assert
      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'Delete failed');
      verify(() => mockRepository.deleteWorkOrder(tWorkOrderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('SyncWorkOrdersUseCase', () {
    final tCompanyId = faker.guid.guid();

    test('should return true on success', () async {
      // Arrange
      when(
        () => mockRepository.syncWorkOrders(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await syncWorkOrdersUseCase(tCompanyId);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.syncWorkOrders(tCompanyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.syncWorkOrders(any()),
      ).thenAnswer((_) async => FailureState<bool>(message: 'Sync failed'));

      // Act
      final result = await syncWorkOrdersUseCase(tCompanyId);

      // Assert
      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'Sync failed');
      verify(() => mockRepository.syncWorkOrders(tCompanyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetWorkOrderChangeRequestsUseCase', () {
    final tCompanyId =
        EntityFactory.makeWorkOrderChangeRequestEntity().companyId;
    final tRequests = EntityFactory.makeWorkOrderChangeRequestEntityList();

    test(
      'should return a list of pending change requests on success',
      () async {
        // Arrange
        when(
          () => mockRepository.getChangeRequests(any()),
        ).thenAnswer((_) async => SuccessState(data: tRequests));

        // Act
        final result = await getWorkOrderChangeRequestsUseCase(tCompanyId);

        // Assert
        expect(result, isA<SuccessState<List<WorkOrderChangeRequestEntity>>>());
        expect(result.data, tRequests);
        verify(() => mockRepository.getChangeRequests(tCompanyId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(() => mockRepository.getChangeRequests(any())).thenAnswer(
        (_) async => FailureState<List<WorkOrderChangeRequestEntity>>(
          message: 'Load failed',
        ),
      );

      // Act
      final result = await getWorkOrderChangeRequestsUseCase(tCompanyId);

      // Assert
      expect(result, isA<FailureState<List<WorkOrderChangeRequestEntity>>>());
      expect(result.message, 'Load failed');
      verify(() => mockRepository.getChangeRequests(tCompanyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetWorkOrderHistoryUseCase', () {
    final tWorkOrderId = EntityFactory.makeWorkOrderEntity().id;
    final tHistory = EntityFactory.makeWorkOrderHistoryEntityList();

    test('should return a list of work order history on success', () async {
      // Arrange
      when(
        () => mockRepository.getWorkOrderHistory(any()),
      ).thenAnswer((_) async => SuccessState(data: tHistory));

      // Act
      final result = await getWorkOrderHistoryUseCase(tWorkOrderId);

      // Assert
      expect(result, isA<SuccessState<List<WorkOrderHistoryEntity>>>());
      expect(result.data, tHistory);
      verify(() => mockRepository.getWorkOrderHistory(tWorkOrderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(() => mockRepository.getWorkOrderHistory(any())).thenAnswer(
        (_) async =>
            FailureState<List<WorkOrderHistoryEntity>>(message: 'Load failed'),
      );

      // Act
      final result = await getWorkOrderHistoryUseCase(tWorkOrderId);

      // Assert
      expect(result, isA<FailureState<List<WorkOrderHistoryEntity>>>());
      expect(result.message, 'Load failed');
      verify(() => mockRepository.getWorkOrderHistory(tWorkOrderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetWorkOrdersUseCase', () {
    final tCompanyId = EntityFactory.makeWorkOrderEntity().companyId;
    final tWorkOrders = EntityFactory.makeWorkOrderEntityList();
    final tParams = GetWorkOrdersParams(companyId: tCompanyId);

    test('should return a list of work orders on success', () async {
      // Arrange
      when(
        () => mockRepository.getWorkOrders(
          any(),
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => SuccessState(data: tWorkOrders));

      // Act
      final result = await getWorkOrdersUseCase(tParams);

      // Assert
      expect(result, isA<SuccessState<List<WorkOrderEntity>>>());
      expect(result.data, tWorkOrders);
      verify(
        () => mockRepository.getWorkOrders(
          tCompanyId,
          filter: tParams.filter,
          pageSize: tParams.pageSize,
          offset: tParams.offset,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.getWorkOrders(
          any(),
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer(
        (_) async =>
            FailureState<List<WorkOrderEntity>>(message: 'Load failed'),
      );

      // Act
      final result = await getWorkOrdersUseCase(tParams);

      // Assert
      expect(result, isA<FailureState<List<WorkOrderEntity>>>());
      expect(result.message, 'Load failed');
      verify(
        () => mockRepository.getWorkOrders(
          tCompanyId,
          filter: tParams.filter,
          pageSize: tParams.pageSize,
          offset: tParams.offset,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetWorkOrderByIdUseCase', () {
    final tWorkOrder = EntityFactory.makeWorkOrderEntity();
    final tId = tWorkOrder.id;

    test('should return a work order on success', () async {
      // Arrange
      when(
        () => mockRepository.getWorkOrderById(any()),
      ).thenAnswer((_) async => SuccessState(data: tWorkOrder));

      // Act
      final result = await getWorkOrderByIdUseCase(tId);

      // Assert
      expect(result, isA<SuccessState<WorkOrderEntity>>());
      expect(result.data, tWorkOrder);
      verify(() => mockRepository.getWorkOrderById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(() => mockRepository.getWorkOrderById(any())).thenAnswer(
        (_) async => FailureState<WorkOrderEntity>(message: 'Not found'),
      );

      // Act
      final result = await getWorkOrderByIdUseCase(tId);

      // Assert
      expect(result, isA<FailureState<WorkOrderEntity>>());
      expect(result.message, 'Not found');
      verify(() => mockRepository.getWorkOrderById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('ReviewWorkOrderChangeRequestUseCase', () {
    final tParams = ReviewChangeRequestParams(
      id: faker.guid.guid(),
      status: ChangeRequestStatus.approved,
      rejectionReason: faker.lorem.sentence(),
      reviewedById: faker.guid.guid(),
    );

    test('should return true on success', () async {
      // Arrange
      when(
        () => mockRepository.reviewChangeRequest(
          id: any(named: 'id'),
          status: any(named: 'status'),
          rejectionReason: any(named: 'rejectionReason'),
          reviewedById: any(named: 'reviewedById'),
        ),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await reviewWorkOrderChangeRequestUseCase(tParams);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockRepository.reviewChangeRequest(
          id: tParams.id,
          status: tParams.status,
          rejectionReason: tParams.rejectionReason,
          reviewedById: tParams.reviewedById,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.reviewChangeRequest(
          id: any(named: 'id'),
          status: any(named: 'status'),
          rejectionReason: any(named: 'rejectionReason'),
          reviewedById: any(named: 'reviewedById'),
        ),
      ).thenAnswer((_) async => FailureState<bool>(message: 'Review failed'));

      // Act
      final result = await reviewWorkOrderChangeRequestUseCase(tParams);

      // Assert
      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'Review failed');
      verify(
        () => mockRepository.reviewChangeRequest(
          id: tParams.id,
          status: tParams.status,
          rejectionReason: tParams.rejectionReason,
          reviewedById: tParams.reviewedById,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('UpdateWorkOrderUseCase', () {
    final tWorkOrder = EntityFactory.makeWorkOrderEntity();

    test('should return true on success', () async {
      // Arrange
      when(
        () => mockRepository.updateWorkOrder(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await updateWorkOrderUseCase(tWorkOrder);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.updateWorkOrder(tWorkOrder)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.updateWorkOrder(any()),
      ).thenAnswer((_) async => FailureState<bool>(message: 'Update failed'));

      // Act
      final result = await updateWorkOrderUseCase(tWorkOrder);

      // Assert
      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'Update failed');
      verify(() => mockRepository.updateWorkOrder(tWorkOrder)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('GetPauseReasonsUseCase', () {
    final tCompanyId = faker.guid.guid();
    final tReasons = EntityFactory.makePauseReasonEntityList();

    test('should return list of pause reasons on success', () async {
      when(
        () => mockPauseRepository.getPauseReasons(any()),
      ).thenAnswer((_) async => SuccessState(data: tReasons));

      final result = await getPauseReasonsUseCase(tCompanyId);

      expect(result, isA<SuccessState<List<dynamic>>>());
      expect(result.data, tReasons);
      verify(() => mockPauseRepository.getPauseReasons(tCompanyId)).called(1);
    });
  });

  group('GetPauseRequestsUseCase', () {
    final tWorkOrderId = faker.guid.guid();
    final tRequests = EntityFactory.makePauseRequestEntityList();

    test('should return list of pause requests on success', () async {
      when(
        () => mockPauseRepository.getPauseRequests(
          any(),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => SuccessState(data: tRequests));

      final result = await getPauseRequestsUseCase(
        GetPauseRequestsParams(workOrderId: tWorkOrderId),
      );

      expect(result, isA<SuccessState<List<dynamic>>>());
      expect(result.data, tRequests);
      verify(
        () => mockPauseRepository.getPauseRequests(tWorkOrderId),
      ).called(1);
    });

    test('should pass status to repository when provided', () async {
      when(
        () => mockPauseRepository.getPauseRequests(
          any(),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => SuccessState(data: tRequests));

      final result = await getPauseRequestsUseCase(
        GetPauseRequestsParams(
          workOrderId: tWorkOrderId,
          status: PauseRequestStatus.pending,
        ),
      );

      expect(result, isA<SuccessState<List<dynamic>>>());
      expect(result.data, tRequests);
      verify(
        () => mockPauseRepository.getPauseRequests(
          tWorkOrderId,
          status: PauseRequestStatus.pending,
        ),
      ).called(1);
    });
  });

  group('RequestPauseUseCase', () {
    final tRequest = EntityFactory.makePauseRequestEntity();

    test('should return true on success', () async {
      when(
        () => mockPauseRepository.requestPause(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await requestPauseUseCase(tRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockPauseRepository.requestPause(tRequest)).called(1);
    });
  });

  group('ReviewPauseUseCase', () {
    final tParams = ReviewPauseParams(
      id: faker.guid.guid(),
      workOrderId: faker.guid.guid(),
      status: PauseRequestStatus.approved,
      reviewedById: faker.guid.guid(),
      reviewObservation: 'Approved',
    );

    test('should return true on success', () async {
      when(
        () => mockPauseRepository.reviewPause(
          id: any(named: 'id'),
          workOrderId: any(named: 'workOrderId'),
          status: any(named: 'status'),
          reviewedById: any(named: 'reviewedById'),
          reviewObservation: any(named: 'reviewObservation'),
          reasonId: any(named: 'reasonId'),
          responsibility: any(named: 'responsibility'),
        ),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await reviewPauseUseCase(tParams);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockPauseRepository.reviewPause(
          id: tParams.id,
          workOrderId: tParams.workOrderId,
          status: tParams.status,
          reviewedById: tParams.reviewedById,
          reviewObservation: tParams.reviewObservation,
        ),
      ).called(1);
    });
  });

  group('CancelPauseUseCase', () {
    final tParams = CancelPauseParams(
      id: faker.guid.guid(),
      workOrderId: faker.guid.guid(),
      resumedAt: DateTime.now(),
      resumedById: faker.guid.guid(),
    );

    test('should return true on success', () async {
      when(
        () => mockPauseRepository.cancelPause(
          id: any(named: 'id'),
          workOrderId: any(named: 'workOrderId'),
          resumedAt: any(named: 'resumedAt'),
          resumedById: any(named: 'resumedById'),
        ),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await cancelPauseUseCase(tParams);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockPauseRepository.cancelPause(
          id: tParams.id,
          workOrderId: tParams.workOrderId,
          resumedAt: tParams.resumedAt,
          resumedById: tParams.resumedById,
        ),
      ).called(1);
    });
  });

  group('RequestCompletionUseCase', () {
    final tRequest = EntityFactory.makePauseRequestEntity();

    test(
      'should call requestPause on pauseRepository and return true on success',
      () async {
        when(
          () => mockPauseRepository.requestPause(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await requestCompletionUseCase(tRequest);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockPauseRepository.requestPause(tRequest)).called(1);
      },
    );
  });

  group('ReviewCompletionUseCase', () {
    final tParams = ReviewCompletionParams(
      id: faker.guid.guid(),
      workOrderId: faker.guid.guid(),
      status: PauseRequestStatus.approved,
      reviewedById: faker.guid.guid(),
      reviewObservation: 'Approved completion',
    );

    test(
      'should call reviewCompletion on pauseRepository and return true on success',
      () async {
        when(
          () => mockPauseRepository.reviewCompletion(
            id: any(named: 'id'),
            workOrderId: any(named: 'workOrderId'),
            status: any(named: 'status'),
            reviewedById: any(named: 'reviewedById'),
            reviewObservation: any(named: 'reviewObservation'),
            responsibility: any(named: 'responsibility'),
            completionReason: any(named: 'completionReason'),
            completionSectorId: any(named: 'completionSectorId'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await reviewCompletionUseCase(tParams);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockPauseRepository.reviewCompletion(
            id: tParams.id,
            workOrderId: tParams.workOrderId,
            status: tParams.status,
            reviewedById: tParams.reviewedById,
            reviewObservation: tParams.reviewObservation,
          ),
        ).called(1);
      },
    );
  });

  group('WatchWorkOrdersRealtimeUseCase', () {
    test(
      'should delegate to watchRealtimeWorkOrders on workOrdersRepository',
      () {
        final tEvent = EntityFactory.makeRealtimeEvent<WorkOrderEntity>(
          entity: EntityFactory.makeWorkOrderEntity(),
        );
        when(
          () => mockRepository.watchRealtimeWorkOrders(
            companyId: any(named: 'companyId'),
          ),
        ).thenAnswer((_) => Stream.value(tEvent));

        final stream = watchWorkOrdersRealtimeUseCase(companyId: 'company-123');

        expect(stream, emits(tEvent));
        verify(
          () =>
              mockRepository.watchRealtimeWorkOrders(companyId: 'company-123'),
        ).called(1);
      },
    );
  });

  group('CalculateWorkOrderKpisUseCase', () {
    final now = DateTime(2026, 8, 25, 12);

    test('returns empty metrics when work order list is empty', () {
      final result = calculateWorkOrderKpisUseCase(
        const CalculateWorkOrderKpisParams(workOrders: []),
      );

      expect(result.totalWorkOrders, 0);
      expect(result.completedCount, 0);
      expect(result.deliveryRate, 0.0);
      expect(result.breachRate, 0.0);
      expect(result.mttrMinutes, 0.0);
    });

    test(
      'calculates counts, delivery rate, breach rate, and MTTR correctly',
      () {
        final onTimeCompletedOrder = EntityFactory.makeWorkOrderEntity()
            .copyWith(
              status: WorkOrderStatus.completed,
              createdAt: now.subtract(const Duration(days: 2)),
              startedAt: now.subtract(const Duration(hours: 4)),
              completedAt: now.subtract(const Duration(hours: 2)),
              slaDeadlineAt: now.subtract(const Duration(hours: 1)),
              slaBreached: false,
              netActiveDuration: 120,
            );

        final breachedCompletedOrder = EntityFactory.makeWorkOrderEntity()
            .copyWith(
              status: WorkOrderStatus.completed,
              createdAt: now.subtract(const Duration(days: 3)),
              startedAt: now.subtract(const Duration(hours: 8)),
              completedAt: now.subtract(const Duration(hours: 2)),
              slaDeadlineAt: now.subtract(const Duration(hours: 5)),
              slaBreached: true,
              netActiveDuration: 360,
            );

        final openDelayedOrder = EntityFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.open,
          createdAt: now.subtract(const Duration(days: 1)),
          slaDeadlineAt: now.subtract(const Duration(hours: 2)),
        );

        final inProgressOrder = EntityFactory.makeWorkOrderEntity().copyWith(
          status: WorkOrderStatus.inProgress,
          createdAt: now.subtract(const Duration(days: 1)),
          slaDeadlineAt: now.add(const Duration(hours: 2)),
        );

        final pendingApprovalOrder = EntityFactory.makeWorkOrderEntity()
            .copyWith(
              status: WorkOrderStatus.pendingConclusionApproval,
              createdAt: now.subtract(const Duration(days: 1)),
              slaDeadlineAt: now.add(const Duration(hours: 4)),
            );

        final workOrders = [
          onTimeCompletedOrder,
          breachedCompletedOrder,
          openDelayedOrder,
          inProgressOrder,
          pendingApprovalOrder,
        ];

        final result = calculateWorkOrderKpisUseCase(
          CalculateWorkOrderKpisParams(
            workOrders: workOrders,
            referenceDate: now,
          ),
        );

        expect(result.totalWorkOrders, 5);
        expect(result.completedCount, 2);
        expect(result.completedWithinSlaCount, 1);
        expect(result.slaBreachedCount, 1);
        expect(result.deliveryRate, 50.0);
        expect(result.breachRate, 50.0);
        expect(result.mttrMinutes, 240.0); // (120 + 360) / 2
        expect(result.openCount, 1);
        expect(result.inProgressCount, 1);
        expect(result.pendingApprovalCount, 1);
        expect(result.delayedCount, 1);
      },
    );

    test('filters work orders according to KpiPeriod', () {
      final recentOrder = EntityFactory.makeWorkOrderEntity().copyWith(
        status: WorkOrderStatus.completed,
        createdAt: now.subtract(const Duration(days: 2)),
        startedAt: now.subtract(const Duration(days: 2, hours: 2)),
        completedAt: now.subtract(const Duration(days: 2)),
        slaDeadlineAt: now.subtract(const Duration(days: 1)),
        slaBreached: false,
        netActiveDuration: 60,
      );

      final oldOrder = EntityFactory.makeWorkOrderEntity().copyWith(
        status: WorkOrderStatus.completed,
        createdAt: now.subtract(const Duration(days: 40)),
        completedAt: now.subtract(const Duration(days: 40)),
        slaBreached: true,
        netActiveDuration: 180,
      );

      final workOrders = [recentOrder, oldOrder];

      final resultLast7Days = calculateWorkOrderKpisUseCase(
        CalculateWorkOrderKpisParams(
          workOrders: workOrders,
          period: KpiPeriod.last7Days,
          referenceDate: now,
        ),
      );

      expect(resultLast7Days.totalWorkOrders, 1);
      expect(resultLast7Days.completedCount, 1);
      expect(resultLast7Days.completedWithinSlaCount, 1);
      expect(resultLast7Days.deliveryRate, 100.0);
      expect(resultLast7Days.breachRate, 0.0);
      expect(resultLast7Days.mttrMinutes, 60.0);

      final resultAllTime = calculateWorkOrderKpisUseCase(
        CalculateWorkOrderKpisParams(
          workOrders: workOrders,
          referenceDate: now,
        ),
      );

      expect(resultAllTime.totalWorkOrders, 2);
      expect(resultAllTime.completedCount, 2);
      expect(resultAllTime.deliveryRate, 50.0);
    });
  });
}
