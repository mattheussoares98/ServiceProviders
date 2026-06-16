import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/work_order_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late WorkOrdersRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = WorkOrdersRemoteDataSourceImpl(database: mockDatabase);
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
    test('getWorkOrders should return SuccessState<List<WorkOrderResponseModel>>', () async {
      when(() => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => [tWorkOrderModel.toJson()]);

      final result = await dataSource.getWorkOrders(tCompanyId);

      expect(result, isA<SuccessState<List<WorkOrderResponseModel>>>());
      expect(result.data, hasLength(1));
      expect(result.data!.first.id, tWorkOrderModel.id);
      verify(() => mockDatabase.selectList(
            table: 'work_orders',
            filters: [SupabaseFilter.eq('company_id', tCompanyId)],
          )).called(1);
    });

    test('getWorkOrders should return FailureState when selectList throws', () async {
      when(() => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          )).thenThrow(Exception('database error'));

      final result = await dataSource.getWorkOrders(tCompanyId);

      expect(result, isA<FailureState<List<WorkOrderResponseModel>>>());
    });

    test('getWorkOrderById should return SuccessState<WorkOrderResponseModel> when found', () async {
      when(() => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => tWorkOrderModel.toJson());

      final result = await dataSource.getWorkOrderById(tWorkOrderId);

      expect(result, isA<SuccessState<WorkOrderResponseModel>>());
      expect(result.data!.id, tWorkOrderModel.id);
      verify(() => mockDatabase.selectOne(
            table: 'work_orders',
            filters: [
              SupabaseFilter.eq('id', tWorkOrderId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          )).called(1);
    });

    test('getWorkOrderById should return FailureState when not found', () async {
      when(() => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => null);

      final result = await dataSource.getWorkOrderById(tWorkOrderId);

      expect(result, isA<FailureState<WorkOrderResponseModel>>());
      final failure = result as FailureState<WorkOrderResponseModel>;
      expect(failure.message, 'Ordem de serviço não encontrada.');
    });

    test('createWorkOrder should return SuccessState<bool>(true)', () async {
      when(() => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          )).thenAnswer((_) async => [tWorkOrderModel.toJson()]);

      final result = await dataSource.createWorkOrder(tWorkOrderRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockDatabase.insert(
            table: 'work_orders',
            values: tWorkOrderRequest.toJson(),
          )).called(1);
    });

    test('createWorkOrder should return FailureState when insert throws', () async {
      when(() => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          )).thenThrow(Exception('database error'));

      final result = await dataSource.createWorkOrder(tWorkOrderRequest);

      expect(result, isA<FailureState<bool>>());
    });

    test('updateWorkOrder should return SuccessState<bool>(true)', () async {
      when(() => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => [tWorkOrderModel.toJson()]);

      final result = await dataSource.updateWorkOrder(tWorkOrderRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockDatabase.update(
            table: 'work_orders',
            values: tWorkOrderRequest.toJson(),
            filters: [SupabaseFilter.eq('id', tWorkOrderRequest.id)],
          )).called(1);
    });

    test('deleteWorkOrder should return SuccessState<bool>(true)', () async {
      when(() => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => [tWorkOrderModel.toJson()]);

      final result = await dataSource.deleteWorkOrder(tWorkOrderId);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockDatabase.update(
            table: 'work_orders',
            values: any(named: 'values'),
            filters: [SupabaseFilter.eq('id', tWorkOrderId)],
          )).called(1);
    });
  });

  group('WorkOrdersRemoteDataSourceImpl - Tasks', () {
    test('getTasksByWorkOrder should return SuccessState<List<TaskResponseModel>>', () async {
      when(() => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => [tTaskModel.toJson()]);

      final result = await dataSource.getTasksByWorkOrder(tWorkOrderId);

      expect(result, isA<SuccessState<List<TaskResponseModel>>>());
      expect(result.data, hasLength(1));
      expect(result.data!.first.id, tTaskModel.id);
      verify(() => mockDatabase.selectList(
            table: 'tasks',
            filters: [
              SupabaseFilter.eq('work_order_id', tWorkOrderId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          )).called(1);
    });

    test('createTask should return SuccessState<bool>(true)', () async {
      when(() => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          )).thenAnswer((_) async => [tTaskModel.toJson()]);

      final result = await dataSource.createTask(tTaskRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockDatabase.insert(
            table: 'tasks',
            values: tTaskRequest.toJson(),
          )).called(1);
    });

    test('updateTask should return SuccessState<bool>(true)', () async {
      when(() => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => [tTaskModel.toJson()]);

      final result = await dataSource.updateTask(tTaskRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockDatabase.update(
            table: 'tasks',
            values: tTaskRequest.toJson(),
            filters: [SupabaseFilter.eq('id', tTaskRequest.id)],
          )).called(1);
    });

    test('deleteTask should return SuccessState<bool>(true)', () async {
      when(() => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => [tTaskModel.toJson()]);

      final result = await dataSource.deleteTask(tTaskId);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockDatabase.update(
            table: 'tasks',
            values: any(named: 'values'),
            filters: [SupabaseFilter.eq('id', tTaskId)],
          )).called(1);
    });
  });

  group('WorkOrdersRemoteDataSourceImpl - Change Requests', () {
    test('getChangeRequests should return SuccessState<List<WorkOrderChangeRequestResponseModel>>', () async {
      when(() => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => [tChangeModel.toJson()]);

      final result = await dataSource.getChangeRequests(tCompanyId);

      expect(result, isA<SuccessState<List<WorkOrderChangeRequestResponseModel>>>());
      expect(result.data, hasLength(1));
      expect(result.data!.first.id, tChangeModel.id);
      verify(() => mockDatabase.selectList(
            table: 'work_order_change_requests',
            filters: [
              SupabaseFilter.eq('company_id', tCompanyId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          )).called(1);
    });

    test('createChangeRequest should return SuccessState<bool>(true)', () async {
      when(() => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          )).thenAnswer((_) async => [tChangeModel.toJson()]);

      final result = await dataSource.createChangeRequest(tChangeRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockDatabase.insert(
            table: 'work_order_change_requests',
            values: tChangeRequest.toJson(),
          )).called(1);
    });

    test('reviewChangeRequest should return SuccessState<bool>(true)', () async {
      final tStatus = faker.randomGenerator.element(['approved', 'rejected']);
      final tRejectionReason = faker.lorem.sentence();
      final tReviewerId = faker.guid.guid();

      when(() => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => [tChangeModel.toJson()]);

      final result = await dataSource.reviewChangeRequest(
        id: tChangeId,
        status: tStatus,
        rejectionReason: tRejectionReason,
        reviewedById: tReviewerId,
      );

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(() => mockDatabase.update(
            table: 'work_order_change_requests',
            values: any(named: 'values'),
            filters: [SupabaseFilter.eq('id', tChangeId)],
          )).called(1);
    });
  });

  group('WorkOrdersRemoteDataSourceImpl - History', () {
    test('getWorkOrderHistory should return SuccessState<List<WorkOrderHistoryResponseModel>>', () async {
      when(() => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          )).thenAnswer((_) async => [tHistoryModel.toJson()]);

      final result = await dataSource.getWorkOrderHistory(tWorkOrderId);

      expect(result, isA<SuccessState<List<WorkOrderHistoryResponseModel>>>());
      expect(result.data, hasLength(1));
      expect(result.data!.first.id, tHistoryModel.id);
      verify(() => mockDatabase.selectList(
            table: 'work_order_history',
            filters: [SupabaseFilter.eq('work_order_id', tWorkOrderId)],
          )).called(1);
    });
  });
}
