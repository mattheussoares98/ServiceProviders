import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/create_work_order_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/get_work_order_change_requests_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/update_work_order_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockWorkOrdersRepository mockRepository;

  late CreateWorkOrderChangeRequestUseCase createWorkOrderChangeRequestUseCase;
  late CreateWorkOrderUseCase createWorkOrderUseCase;
  late DeleteWorkOrderUseCase deleteWorkOrderUseCase;
  late GetWorkOrderChangeRequestsUseCase getWorkOrderChangeRequestsUseCase;
  late GetWorkOrderHistoryUseCase getWorkOrderHistoryUseCase;
  late GetWorkOrdersUseCase getWorkOrdersUseCase;
  late ReviewWorkOrderChangeRequestUseCase reviewWorkOrderChangeRequestUseCase;
  late UpdateWorkOrderUseCase updateWorkOrderUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeWorkOrderChangeRequestEntity());
    registerFallbackValue(EntityFactory.makeWorkOrderEntity());
    registerFallbackValue(ChangeRequestStatus.approved);
  });

  setUp(() {
    mockRepository = MockWorkOrdersRepository();

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
  });

  group('CreateWorkOrderChangeRequestUseCase', () {
    final tChangeRequest = EntityFactory.makeWorkOrderChangeRequestEntity();

    test('should return true on success', () async {
      // Arrange
      when(() => mockRepository.createChangeRequest(any()))
          .thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await createWorkOrderChangeRequestUseCase(tChangeRequest);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.createChangeRequest(tChangeRequest)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(() => mockRepository.createChangeRequest(any())).thenAnswer(
        (_) async => FailureState<bool>(message: 'Create failed'),
      );

      // Act
      final result = await createWorkOrderChangeRequestUseCase(tChangeRequest);

      // Assert
      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'Create failed');
      verify(() => mockRepository.createChangeRequest(tChangeRequest)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('CreateWorkOrderUseCase', () {
    final tWorkOrder = EntityFactory.makeWorkOrderEntity();

    test('should return true on success', () async {
      // Arrange
      when(() => mockRepository.createWorkOrder(any()))
          .thenAnswer((_) async => const SuccessState(data: true));

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
      when(() => mockRepository.createWorkOrder(any())).thenAnswer(
        (_) async => FailureState<bool>(message: 'Create failed'),
      );

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
      when(() => mockRepository.deleteWorkOrder(any()))
          .thenAnswer((_) async => const SuccessState(data: true));

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
      when(() => mockRepository.deleteWorkOrder(any())).thenAnswer(
        (_) async => FailureState<bool>(message: 'Delete failed'),
      );

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
    final tCompanyId = EntityFactory.makeWorkOrderChangeRequestEntity().companyId;
    final tRequests = EntityFactory.makeWorkOrderChangeRequestEntityList();

    test('should return a list of pending change requests on success', () async {
      // Arrange
      when(() => mockRepository.getChangeRequests(any()))
          .thenAnswer((_) async => SuccessState(data: tRequests));

      // Act
      final result = await getWorkOrderChangeRequestsUseCase(tCompanyId);

      // Assert
      expect(result, isA<SuccessState<List<WorkOrderChangeRequestEntity>>>());
      expect(result.data, tRequests);
      verify(() => mockRepository.getChangeRequests(tCompanyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(() => mockRepository.getChangeRequests(any())).thenAnswer(
        (_) async =>
            FailureState<List<WorkOrderChangeRequestEntity>>(message: 'Load failed'),
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
      when(() => mockRepository.getWorkOrderHistory(any()))
          .thenAnswer((_) async => SuccessState(data: tHistory));

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

    test('should return a list of work orders on success', () async {
      // Arrange
      when(() => mockRepository.getWorkOrders(any()))
          .thenAnswer((_) async => SuccessState(data: tWorkOrders));

      // Act
      final result = await getWorkOrdersUseCase(tCompanyId);

      // Assert
      expect(result, isA<SuccessState<List<WorkOrderEntity>>>());
      expect(result.data, tWorkOrders);
      verify(() => mockRepository.getWorkOrders(tCompanyId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(() => mockRepository.getWorkOrders(any())).thenAnswer(
        (_) async =>
            FailureState<List<WorkOrderEntity>>(message: 'Load failed'),
      );

      // Act
      final result = await getWorkOrdersUseCase(tCompanyId);

      // Assert
      expect(result, isA<FailureState<List<WorkOrderEntity>>>());
      expect(result.message, 'Load failed');
      verify(() => mockRepository.getWorkOrders(tCompanyId)).called(1);
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
      when(() => mockRepository.updateWorkOrder(any()))
          .thenAnswer((_) async => const SuccessState(data: true));

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
      when(() => mockRepository.updateWorkOrder(any())).thenAnswer(
        (_) async => FailureState<bool>(message: 'Update failed'),
      );

      // Act
      final result = await updateWorkOrderUseCase(tWorkOrder);

      // Assert
      expect(result, isA<FailureState<bool>>());
      expect(result.message, 'Update failed');
      verify(() => mockRepository.updateWorkOrder(tWorkOrder)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
