import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/repositories/work_orders_repository_impl.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/task_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockWorkOrdersRemoteDataSource mockRemoteDataSource;
  late MockWorkOrdersLocalDataSource mockLocalDataSource;
  late WorkOrdersRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      WorkOrderResponseModel.fromEntity(EntityFactory.makeWorkOrderEntity()),
    );
    registerFallbackValue(
      TaskResponseModel.fromEntity(EntityFactory.makeTaskEntity()),
    );
    registerFallbackValue(
      WorkOrderChangeRequestResponseModel.fromEntity(
        EntityFactory.makeWorkOrderChangeRequestEntity(),
      ),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockWorkOrdersRemoteDataSource();
    mockLocalDataSource = MockWorkOrdersLocalDataSource();
    repository = WorkOrdersRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity();
  final tWorkOrderModel = WorkOrderResponseModel.fromEntity(tWorkOrderEntity);

  final tTaskEntity = EntityFactory.makeTaskEntity();
  final tTaskModel = TaskResponseModel.fromEntity(tTaskEntity);

  final tChangeEntity = EntityFactory.makeWorkOrderChangeRequestEntity();
  final tChangeModel = WorkOrderChangeRequestResponseModel.fromEntity(
    tChangeEntity,
  );

  final tHistoryEntity = EntityFactory.makeWorkOrderHistoryEntity();
  final tHistoryModel = WorkOrderHistoryResponseModel.fromEntity(
    tHistoryEntity,
  );

  final tCompanyId = faker.guid.guid();
  final tWorkOrderId = faker.guid.guid();
  final tTaskId = faker.guid.guid();
  final tChangeId = faker.guid.guid();

  group('WorkOrdersRepositoryImpl - Work Orders', () {
    group('getWorkOrders', () {
      test(
        'should return SuccessState<List<WorkOrderEntity>> when local data source is successful',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getWorkOrders(any()),
          ).thenAnswer((_) async => SuccessState(data: [tWorkOrderModel]));

          // Act
          final result = await repository.getWorkOrders(tCompanyId);

          // Assert
          expect(result, isA<SuccessState<List<WorkOrderEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tWorkOrderModel.id);
          verify(() => mockLocalDataSource.getWorkOrders(tCompanyId)).called(1);
        },
      );

      test('should return FailureState when local data source fails', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getWorkOrders(any()),
        ).thenAnswer((_) async => FailureState(message: 'Database error'));

        // Act
        final result = await repository.getWorkOrders(tCompanyId);

        // Assert
        expect(result, isA<FailureState<List<WorkOrderEntity>>>());
        expect(result.message, 'Database error');
      });
    });

    group('getWorkOrderById', () {
      test(
        'should return SuccessState<WorkOrderEntity> when local data source returns work order',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getWorkOrderById(any()),
          ).thenAnswer((_) async => SuccessState(data: tWorkOrderModel));

          // Act
          final result = await repository.getWorkOrderById(tWorkOrderId);

          // Assert
          expect(result, isA<SuccessState<WorkOrderEntity>>());
          expect(result.data!.id, tWorkOrderModel.id);
          verify(
            () => mockLocalDataSource.getWorkOrderById(tWorkOrderId),
          ).called(1);
        },
      );

      test(
        'should return FailureState when local data source fails to find work order',
        () async {
          // Arrange
          when(() => mockLocalDataSource.getWorkOrderById(any())).thenAnswer(
            (_) async => FailureState(message: 'Work order not found'),
          );

          // Act
          final result = await repository.getWorkOrderById(tWorkOrderId);

          // Assert
          expect(result, isA<FailureState<WorkOrderEntity>>());
          expect(result.message, 'Work order not found');
        },
      );
    });

    group('createWorkOrder', () {
      test(
        'should return SuccessState<bool>(true) when save is successful locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveWorkOrder(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createWorkOrder(tWorkOrderEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveWorkOrder(any())).called(1);
        },
      );
    });

    group('updateWorkOrder', () {
      test(
        'should return SuccessState<bool>(true) when update is successful locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveWorkOrder(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.updateWorkOrder(tWorkOrderEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveWorkOrder(any())).called(1);
        },
      );
    });

    group('deleteWorkOrder', () {
      test(
        'should return SuccessState<bool>(true) when deletion is successful locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.deleteWorkOrder(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.deleteWorkOrder(tWorkOrderId);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.deleteWorkOrder(tWorkOrderId),
          ).called(1);
        },
      );
    });
  });

  group('WorkOrdersRepositoryImpl - Tasks', () {
    group('getTasksByWorkOrder', () {
      test(
        'should return SuccessState<List<TaskEntity>> when local call is successful',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getTasksByWorkOrder(any()),
          ).thenAnswer((_) async => SuccessState(data: [tTaskModel]));

          // Act
          final result = await repository.getTasksByWorkOrder(tWorkOrderId);

          // Assert
          expect(result, isA<SuccessState<List<TaskEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tTaskModel.id);
          verify(
            () => mockLocalDataSource.getTasksByWorkOrder(tWorkOrderId),
          ).called(1);
        },
      );
    });

    group('createTask', () {
      test(
        'should return SuccessState<bool>(true) when save is successful locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveTask(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createTask(tTaskEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveTask(any())).called(1);
        },
      );
    });

    group('updateTask', () {
      test(
        'should return SuccessState<bool>(true) when update is successful locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveTask(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.updateTask(tTaskEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveTask(any())).called(1);
        },
      );
    });

    group('deleteTask', () {
      test(
        'should return SuccessState<bool>(true) when deletion is successful locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.deleteTask(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.deleteTask(tTaskId);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.deleteTask(tTaskId)).called(1);
        },
      );
    });
  });

  group('WorkOrdersRepositoryImpl - Change Requests', () {
    group('getChangeRequests', () {
      test(
        'should return SuccessState<List<WorkOrderChangeRequestEntity>> when local call is successful',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getChangeRequests(any()),
          ).thenAnswer((_) async => SuccessState(data: [tChangeModel]));

          // Act
          final result = await repository.getChangeRequests(tCompanyId);

          // Assert
          expect(
            result,
            isA<SuccessState<List<WorkOrderChangeRequestEntity>>>(),
          );
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tChangeModel.id);
          verify(
            () => mockLocalDataSource.getChangeRequests(tCompanyId),
          ).called(1);
        },
      );
    });

    group('createChangeRequest', () {
      test(
        'should return SuccessState<bool>(true) when save is successful locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveChangeRequest(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createChangeRequest(tChangeEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveChangeRequest(any())).called(1);
        },
      );
    });

    group('reviewChangeRequest', () {
      test(
        'should return SuccessState<bool>(true) when review is successful locally',
        () async {
          // Arrange
          const tStatus = ChangeRequestStatus.approved;
          final tReason = faker.lorem.sentence();
          final tReviewerId = faker.guid.guid();

          when(
            () => mockLocalDataSource.reviewChangeRequest(
              id: any(named: 'id'),
              status: any(named: 'status'),
              rejectionReason: any(named: 'rejectionReason'),
              reviewedById: any(named: 'reviewedById'),
            ),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.reviewChangeRequest(
            id: tChangeId,
            status: tStatus,
            rejectionReason: tReason,
            reviewedById: tReviewerId,
          );

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.reviewChangeRequest(
              id: tChangeId,
              status: tStatus.code,
              rejectionReason: tReason,
              reviewedById: tReviewerId,
            ),
          ).called(1);
        },
      );
    });
  });

  group('WorkOrdersRepositoryImpl - History', () {
    group('getWorkOrderHistory', () {
      test(
        'should return SuccessState<List<WorkOrderHistoryEntity>> when local call is successful',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getWorkOrderHistory(any()),
          ).thenAnswer((_) async => SuccessState(data: [tHistoryModel]));

          // Act
          final result = await repository.getWorkOrderHistory(tWorkOrderId);

          // Assert
          expect(result, isA<SuccessState<List<WorkOrderHistoryEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tHistoryModel.id);
          verify(
            () => mockLocalDataSource.getWorkOrderHistory(tWorkOrderId),
          ).called(1);
        },
      );
    });
  });
}
