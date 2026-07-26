import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_sla_policy_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_reasons_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_sla_policies_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_sla_policy_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_change_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockWorkOrdersRepository mockRepository;
  late MockSlaRepository mockSlaRepository;
  late MockPauseRepository mockPauseRepository;

  late CreateWorkOrderChangeRequestUseCase createWorkOrderChangeRequestUseCase;
  late CreateWorkOrderUseCase createWorkOrderUseCase;
  late DeleteWorkOrderUseCase deleteWorkOrderUseCase;
  late GetWorkOrderChangeRequestsUseCase getWorkOrderChangeRequestsUseCase;
  late GetWorkOrderHistoryUseCase getWorkOrderHistoryUseCase;
  late GetWorkOrdersUseCase getWorkOrdersUseCase;
  late ReviewWorkOrderChangeRequestUseCase reviewWorkOrderChangeRequestUseCase;
  late UpdateWorkOrderUseCase updateWorkOrderUseCase;

  late GetSlaPoliciesUseCase getSlaPoliciesUseCase;
  late GetSlaPolicyByIdUseCase getSlaPolicyByIdUseCase;
  late CreateSlaPolicyUseCase createSlaPolicyUseCase;
  late GetPauseReasonsUseCase getPauseReasonsUseCase;
  late GetPauseRequestsUseCase getPauseRequestsUseCase;
  late RequestPauseUseCase requestPauseUseCase;
  late ReviewPauseUseCase reviewPauseUseCase;
  late CancelPauseUseCase cancelPauseUseCase;
  late RequestCompletionUseCase requestCompletionUseCase;
  late ReviewCompletionUseCase reviewCompletionUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeWorkOrderChangeRequestEntity());
    registerFallbackValue(EntityFactory.makeWorkOrderEntity());
    registerFallbackValue(ChangeRequestStatus.approved);
    registerFallbackValue(const WorkOrderFilter());
    registerFallbackValue(EntityFactory.makeServiceProviderCompanyEntity());
    registerFallbackValue(EntityFactory.makeServiceProviderProfileEntity());
    registerFallbackValue(EntityFactory.makeSlaPolicyEntity());
    registerFallbackValue(EntityFactory.makePauseReasonEntity());
    registerFallbackValue(EntityFactory.makePauseRequestEntity());
    registerFallbackValue(PauseRequestStatus.pending);
    registerFallbackValue(
      ReviewPauseParams(
        id: faker.guid.guid(),
        status: PauseRequestStatus.approved,
        reviewedById: faker.guid.guid(),
      ),
    );
    registerFallbackValue(
      CancelPauseParams(id: faker.guid.guid(), resumedAt: DateTime.now()),
    );
  });

  setUp(() {
    mockRepository = MockWorkOrdersRepository();
    mockSlaRepository = MockSlaRepository();
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
    reviewWorkOrderChangeRequestUseCase = ReviewWorkOrderChangeRequestUseCase(
      workOrdersRepository: mockRepository,
    );
    updateWorkOrderUseCase = UpdateWorkOrderUseCase(
      workOrdersRepository: mockRepository,
    );

    getSlaPoliciesUseCase = GetSlaPoliciesUseCase(
      slaRepository: mockSlaRepository,
    );
    getSlaPolicyByIdUseCase = GetSlaPolicyByIdUseCase(
      slaRepository: mockSlaRepository,
    );
    createSlaPolicyUseCase = CreateSlaPolicyUseCase(
      slaRepository: mockSlaRepository,
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

  group('GetSlaPoliciesUseCase', () {
    final tCompanyId = faker.guid.guid();
    final tSlaPolicies = EntityFactory.makeSlaPolicyEntityList();

    test('should return list of SLA policies on success', () async {
      when(
        () => mockSlaRepository.getSlaPolicies(any()),
      ).thenAnswer((_) async => SuccessState(data: tSlaPolicies));

      final result = await getSlaPoliciesUseCase(tCompanyId);

      expect(result, isA<SuccessState<List<dynamic>>>());
      expect(result.data, tSlaPolicies);
      verify(() => mockSlaRepository.getSlaPolicies(tCompanyId)).called(1);
    });
  });

  group('GetSlaPolicyByIdUseCase', () {
    final tId = faker.guid.guid();
    final tSlaPolicy = EntityFactory.makeSlaPolicyEntity();

    test('should return SLA policy on success', () async {
      when(
        () => mockSlaRepository.getSlaPolicyById(any()),
      ).thenAnswer((_) async => SuccessState(data: tSlaPolicy));

      final result = await getSlaPolicyByIdUseCase(tId);

      expect(result, isA<SuccessState<dynamic>>());
      expect(result.data, tSlaPolicy);
      verify(() => mockSlaRepository.getSlaPolicyById(tId)).called(1);
    });
  });

  group('CreateSlaPolicyUseCase', () {
    final tSlaPolicy = EntityFactory.makeSlaPolicyEntity();

    test('should return true on success', () async {
      when(
        () => mockSlaRepository.createSlaPolicy(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await createSlaPolicyUseCase(tSlaPolicy);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockSlaRepository.createSlaPolicy(tSlaPolicy)).called(1);
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
        () => mockPauseRepository.getPauseRequests(any()),
      ).thenAnswer((_) async => SuccessState(data: tRequests));

      final result = await getPauseRequestsUseCase(tWorkOrderId);

      expect(result, isA<SuccessState<List<dynamic>>>());
      expect(result.data, tRequests);
      verify(
        () => mockPauseRepository.getPauseRequests(tWorkOrderId),
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
      status: PauseRequestStatus.approved,
      reviewedById: faker.guid.guid(),
      reviewObservation: 'Approved',
    );

    test('should return true on success', () async {
      when(
        () => mockPauseRepository.reviewPause(
          id: any(named: 'id'),
          status: any(named: 'status'),
          reviewedById: any(named: 'reviewedById'),
          reviewObservation: any(named: 'reviewObservation'),
        ),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await reviewPauseUseCase(tParams);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockPauseRepository.reviewPause(
          id: tParams.id,
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
      resumedAt: DateTime.now(),
    );

    test('should return true on success', () async {
      when(
        () => mockPauseRepository.cancelPause(
          id: any(named: 'id'),
          resumedAt: any(named: 'resumedAt'),
        ),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await cancelPauseUseCase(tParams);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockPauseRepository.cancelPause(
          id: tParams.id,
          resumedAt: tParams.resumedAt,
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
      status: PauseRequestStatus.approved,
      reviewedById: faker.guid.guid(),
      reviewObservation: 'Approved completion',
    );

    test(
      'should call reviewPause on pauseRepository and return true on success',
      () async {
        when(
          () => mockPauseRepository.reviewPause(
            id: any(named: 'id'),
            status: any(named: 'status'),
            reviewedById: any(named: 'reviewedById'),
            reviewObservation: any(named: 'reviewObservation'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await reviewCompletionUseCase(tParams);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockPauseRepository.reviewPause(
            id: tParams.id,
            status: tParams.status,
            reviewedById: tParams.reviewedById,
            reviewObservation: tParams.reviewObservation,
          ),
        ).called(1);
      },
    );
  });
}
