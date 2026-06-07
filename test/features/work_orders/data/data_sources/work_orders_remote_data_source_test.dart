import 'package:clean_architecture/core/constants/api_endpoints.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/work_order_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late WorkOrdersRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = WorkOrdersRemoteDataSourceImpl(httpClient: mockHttpClient);
  });

  final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity();
  final tWorkOrderModel = WorkOrderResponseModel.fromEntity(tWorkOrderEntity);
  final tWorkOrderRequest = WorkOrderRequestModel.fromEntity(tWorkOrderEntity);

  final tTaskEntity = EntityFactory.makeTaskEntity();
  final tTaskModel = TaskResponseModel.fromEntity(tTaskEntity);
  final tTaskRequest = TaskRequestModel.fromEntity(tTaskEntity);

  final tChangeEntity = EntityFactory.makeWorkOrderChangeRequestEntity();
  final tChangeModel = WorkOrderChangeRequestResponseModel.fromEntity(tChangeEntity);
  final tChangeRequest = WorkOrderChangeRequestRequestModel.fromEntity(tChangeEntity);

  final tHistoryEntity = EntityFactory.makeWorkOrderHistoryEntity();
  final tHistoryModel = WorkOrderHistoryResponseModel.fromEntity(tHistoryEntity);

  final tCompanyId = faker.guid.guid();
  final tWorkOrderId = faker.guid.guid();
  final tTaskId = faker.guid.guid();
  final tChangeId = faker.guid.guid();

  group('WorkOrdersRemoteDataSourceImpl - Work Orders', () {
    test('getWorkOrders should return SuccessState<List<WorkOrderResponseModel>> on 200', () async {
      // Arrange
      final fakeResponse = {
        'data': [tWorkOrderModel.toJson()],
        'message': 'Success',
      };

      when(() => mockHttpClient.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.workOrders),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.getWorkOrders(tCompanyId);

      // Assert
      expect(result, isA<SuccessState<List<WorkOrderResponseModel>>>());
      expect(result.data, hasLength(1));
      expect(result.data!.first.id, tWorkOrderModel.id);
      verify(() => mockHttpClient.get<dynamic>(
            ApiEndpoints.workOrders,
            queryParameters: {'company_id': tCompanyId},
          )).called(1);
    });

    test('getWorkOrderById should return SuccessState<WorkOrderResponseModel> on 200', () async {
      // Arrange
      final fakeResponse = {
        'data': tWorkOrderModel.toJson(),
        'message': 'Success',
      };

      when(() => mockHttpClient.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.workOrderById(tWorkOrderId)),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.getWorkOrderById(tWorkOrderId);

      // Assert
      expect(result, isA<SuccessState<WorkOrderResponseModel>>());
      expect(result.data!.id, tWorkOrderModel.id);
      verify(() => mockHttpClient.get<dynamic>(ApiEndpoints.workOrderById(tWorkOrderId))).called(1);
    });

    test('createWorkOrder should return SuccessState<bool>(true) on 200', () async {
      // Arrange
      final fakeResponse = {'message': 'Created'};

      when(() => mockHttpClient.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.workOrders),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.createWorkOrder(tWorkOrderRequest);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockHttpClient.post<dynamic>(
            ApiEndpoints.workOrders,
            data: tWorkOrderRequest.toJson(),
          )).called(1);
    });

    test('updateWorkOrder should return SuccessState<bool>(true) on 200', () async {
      // Arrange
      final fakeResponse = {'message': 'Updated'};

      when(() => mockHttpClient.put<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.workOrderById(tWorkOrderRequest.id)),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.updateWorkOrder(tWorkOrderRequest);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockHttpClient.put<dynamic>(
            ApiEndpoints.workOrderById(tWorkOrderRequest.id),
            data: tWorkOrderRequest.toJson(),
          )).called(1);
    });

    test('deleteWorkOrder should return SuccessState<bool>(true) on 200', () async {
      // Arrange
      final fakeResponse = {'message': 'Deleted'};

      when(() => mockHttpClient.delete<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.workOrderById(tWorkOrderId)),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.deleteWorkOrder(tWorkOrderId);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockHttpClient.delete<dynamic>(ApiEndpoints.workOrderById(tWorkOrderId))).called(1);
    });
  });

  group('WorkOrdersRemoteDataSourceImpl - Tasks', () {
    test('getTasksByWorkOrder should return SuccessState<List<TaskResponseModel>> on 200', () async {
      // Arrange
      final fakeResponse = {
        'data': [tTaskModel.toJson()],
        'message': 'Success',
      };

      when(() => mockHttpClient.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.tasks),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.getTasksByWorkOrder(tWorkOrderId);

      // Assert
      expect(result, isA<SuccessState<List<TaskResponseModel>>>());
      expect(result.data, hasLength(1));
      expect(result.data!.first.id, tTaskModel.id);
      verify(() => mockHttpClient.get<dynamic>(
            ApiEndpoints.tasks,
            queryParameters: {'work_order_id': tWorkOrderId},
          )).called(1);
    });

    test('createTask should return SuccessState<bool>(true) on 200', () async {
      // Arrange
      final fakeResponse = {'message': 'Created'};

      when(() => mockHttpClient.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.tasks),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.createTask(tTaskRequest);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockHttpClient.post<dynamic>(
            ApiEndpoints.tasks,
            data: tTaskRequest.toJson(),
          )).called(1);
    });

    test('updateTask should return SuccessState<bool>(true) on 200', () async {
      // Arrange
      final fakeResponse = {'message': 'Updated'};

      when(() => mockHttpClient.put<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.taskById(tTaskRequest.id)),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.updateTask(tTaskRequest);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockHttpClient.put<dynamic>(
            ApiEndpoints.taskById(tTaskRequest.id),
            data: tTaskRequest.toJson(),
          )).called(1);
    });

    test('deleteTask should return SuccessState<bool>(true) on 200', () async {
      // Arrange
      final fakeResponse = {'message': 'Deleted'};

      when(() => mockHttpClient.delete<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.taskById(tTaskId)),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.deleteTask(tTaskId);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockHttpClient.delete<dynamic>(ApiEndpoints.taskById(tTaskId))).called(1);
    });
  });

  group('WorkOrdersRemoteDataSourceImpl - Change Requests', () {
    test('getChangeRequests should return SuccessState<List<WorkOrderChangeRequestResponseModel>> on 200', () async {
      // Arrange
      final fakeResponse = {
        'data': [tChangeModel.toJson()],
        'message': 'Success',
      };

      when(() => mockHttpClient.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.changeRequests),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.getChangeRequests(tCompanyId);

      // Assert
      expect(result, isA<SuccessState<List<WorkOrderChangeRequestResponseModel>>>());
      expect(result.data, hasLength(1));
      expect(result.data!.first.id, tChangeModel.id);
      verify(() => mockHttpClient.get<dynamic>(
            ApiEndpoints.changeRequests,
            queryParameters: {'company_id': tCompanyId},
          )).called(1);
    });

    test('createChangeRequest should return SuccessState<bool>(true) on 200', () async {
      // Arrange
      final fakeResponse = {'message': 'Created'};

      when(() => mockHttpClient.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.changeRequests),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.createChangeRequest(tChangeRequest);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockHttpClient.post<dynamic>(
            ApiEndpoints.changeRequests,
            data: tChangeRequest.toJson(),
          )).called(1);
    });

    test('reviewChangeRequest should return SuccessState<bool>(true) on 200', () async {
      // Arrange
      final fakeResponse = {'message': 'Reviewed'};
      final tStatus = faker.randomGenerator.element(['approved', 'rejected']);
      final tRejectionReason = faker.lorem.sentence();
      final tReviewerId = faker.guid.guid();

      when(() => mockHttpClient.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '${ApiEndpoints.changeRequests}/$tChangeId/review'),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.reviewChangeRequest(
        id: tChangeId,
        status: tStatus,
        rejectionReason: tRejectionReason,
        reviewedById: tReviewerId,
      );

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockHttpClient.post<dynamic>(
            '${ApiEndpoints.changeRequests}/$tChangeId/review',
            data: {
              'status': tStatus,
              'rejection_reason': tRejectionReason,
              'reviewed_by_id': tReviewerId,
            },
          )).called(1);
    });
  });

  group('WorkOrdersRemoteDataSourceImpl - History', () {
    test('getWorkOrderHistory should return SuccessState<List<WorkOrderHistoryResponseModel>> on 200', () async {
      // Arrange
      final fakeResponse = {
        'data': [tHistoryModel.toJson()],
        'message': 'Success',
      };

      when(() => mockHttpClient.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.workOrderHistory),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.getWorkOrderHistory(tWorkOrderId);

      // Assert
      expect(result, isA<SuccessState<List<WorkOrderHistoryResponseModel>>>());
      expect(result.data, hasLength(1));
      expect(result.data!.first.id, tHistoryModel.id);
      verify(() => mockHttpClient.get<dynamic>(
            ApiEndpoints.workOrderHistory,
            queryParameters: {'work_order_id': tWorkOrderId},
          )).called(1);
    });
  });
}
