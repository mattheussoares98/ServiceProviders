import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_order.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late WorkOrdersRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
    registerFallbackValue(<SupabaseOrder>[]);
    registerFallbackValue(const WorkOrderFilter());
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = WorkOrdersRemoteDataSourceImpl(database: mockDatabase);
  });

  final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity();
  final tWorkOrderModel = WorkOrderModel.fromEntity(tWorkOrderEntity);
  final tWorkOrderRequest = WorkOrderModel.fromEntity(tWorkOrderEntity);

  final tTaskEntity = EntityFactory.makeTaskEntity();
  final tTaskModel = TaskModel.fromEntity(tTaskEntity);
  final tTaskRequest = TaskRequestModel.fromEntity(tTaskEntity);

  final tChangeEntity = EntityFactory.makeWorkOrderChangeRequestEntity();
  final tChangeModel = WorkOrderChangeRequestModel.fromEntity(tChangeEntity);
  final tChangeRequest = WorkOrderChangeRequestRequestModel.fromEntity(
    tChangeEntity,
  );

  final tHistoryEntity = EntityFactory.makeWorkOrderHistoryEntity();
  final tHistoryModel = WorkOrderHistoryModel.fromEntity(tHistoryEntity);

  final tCompanyId = faker.guid.guid();
  final tWorkOrderId = faker.guid.guid();
  final tTaskId = faker.guid.guid();
  final tChangeId = faker.guid.guid();

  group('WorkOrdersRemoteDataSourceImpl - Work Orders', () {
    test(
      'getWorkOrders should return SuccessState<List<WorkOrderModel>>',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
            orderBy: any(named: 'orderBy'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [tWorkOrderModel.toJson()]);

        final result = await dataSource.getWorkOrders(tCompanyId);

        expect(result, isA<SuccessState<List<WorkOrderModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tWorkOrderModel.id);
        verify(
          () => mockDatabase.selectList(
            table: 'work_orders',
            columns: '*, locations!inner(deleted_at), attachments(*)',
            filters: any(named: 'filters'),
            orderBy: any(named: 'orderBy'),
            limit: 20,
            offset: 0,
          ),
        ).called(1);
      },
    );

    test(
      'getWorkOrders should properly construct filters list and call remote client with them',
      () async {
        final filter = WorkOrderFilter(
          statuses: const [WorkOrderStatus.open],
          priorities: const [Priority.high],
          type: WorkOrderType.preventive,
          assignedToId: 'user-123',
          scheduledDateFrom: DateTime(2026, 7, 14),
          scheduledDateTo: DateTime(2026, 7, 16),
          searchText: 'manutencao',
        );

        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
            orderBy: any(named: 'orderBy'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [tWorkOrderModel.toJson()]);

        final result = await dataSource.getWorkOrders(
          tCompanyId,
          filter: filter,
          pageSize: 10,
          offset: 5,
        );

        expect(result, isA<SuccessState<List<WorkOrderModel>>>());

        final capturedFilters =
            verify(
                  () => mockDatabase.selectList(
                    table: 'work_orders',
                    columns: '*, locations!inner(deleted_at), attachments(*)',
                    filters: captureAny(named: 'filters'),
                    orderBy: any(named: 'orderBy'),
                    limit: 10,
                    offset: 5,
                  ),
                ).captured.first
                as List<SupabaseFilter>;

        expect(
          capturedFilters,
          contains(SupabaseFilter.eq('company_id', tCompanyId)),
        );
        expect(
          capturedFilters,
          contains(SupabaseFilter.isFilter('deleted_at', null)),
        );
        expect(
          capturedFilters,
          contains(SupabaseFilter.isFilter('locations.deleted_at', null)),
        );
        expect(
          capturedFilters,
          contains(SupabaseFilter.inList('status', const ['open'])),
        );
        expect(
          capturedFilters,
          contains(SupabaseFilter.inList('priority', const ['high'])),
        );
        expect(
          capturedFilters,
          contains(SupabaseFilter.eq('type', 'preventive')),
        );
        expect(
          capturedFilters,
          contains(SupabaseFilter.eq('assigned_to_id', 'user-123')),
        );
        expect(
          capturedFilters,
          contains(
            SupabaseFilter.gte(
              'scheduled_date',
              DateTime(2026, 7, 14).toIso8601String(),
            ),
          ),
        );
        expect(
          capturedFilters,
          contains(
            SupabaseFilter.lte(
              'scheduled_date',
              DateTime(2026, 7, 16).toIso8601String(),
            ),
          ),
        );
        expect(
          capturedFilters,
          contains(SupabaseFilter.ilike('title', '%manutencao%')),
        );
      },
    );

    test(
      'getWorkOrders should return FailureState when selectList throws',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
            orderBy: any(named: 'orderBy'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(Exception('database error'));

        final result = await dataSource.getWorkOrders(tCompanyId);

        expect(result, isA<FailureState<List<WorkOrderModel>>>());
      },
    );

    test(
      'getWorkOrderById should return SuccessState<WorkOrderModel> when found',
      () async {
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => tWorkOrderModel.toJson());

        final result = await dataSource.getWorkOrderById(tWorkOrderId);

        expect(result, isA<SuccessState<WorkOrderModel>>());
        expect(result.data!.id, tWorkOrderModel.id);
        verify(
          () => mockDatabase.selectOne(
            table: 'work_orders',
            columns: '*, locations!inner(deleted_at), attachments(*)',
            filters: [
              SupabaseFilter.eq('id', tWorkOrderId),
              SupabaseFilter.isFilter('deleted_at', null),
              SupabaseFilter.isFilter('locations.deleted_at', null),
            ],
          ),
        ).called(1);
      },
    );

    test(
      'getWorkOrderById should return FailureState when not found',
      () async {
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            columns: any(named: 'columns'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => null);

        final result = await dataSource.getWorkOrderById(tWorkOrderId);

        expect(result, isA<FailureState<WorkOrderModel>>());
        final failure = result as FailureState<WorkOrderModel>;
        expect(failure.message, 'Ordem de serviço não encontrada.');
        verify(
          () => mockDatabase.selectOne(
            table: 'work_orders',
            columns: '*, locations!inner(deleted_at), attachments(*)',
            filters: [
              SupabaseFilter.eq('id', tWorkOrderId),
              SupabaseFilter.isFilter('deleted_at', null),
              SupabaseFilter.isFilter('locations.deleted_at', null),
            ],
          ),
        ).called(1);
      },
    );

    test('createWorkOrder should return SuccessState<bool>(true)', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenAnswer((_) async => [tWorkOrderModel.toJson()]);

      final result = await dataSource.createWorkOrder(tWorkOrderRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(
        () => mockDatabase.insert(
          table: 'work_orders',
          values: tWorkOrderRequest.toJson(),
        ),
      ).called(1);
    });

    test(
      'createWorkOrder should return FailureState when insert throws',
      () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenThrow(Exception('database error'));

        final result = await dataSource.createWorkOrder(tWorkOrderRequest);

        expect(result, isA<FailureState<bool>>());
      },
    );

    test('updateWorkOrder should return SuccessState<bool>(true)', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tWorkOrderModel.toJson()]);

      final result = await dataSource.updateWorkOrder(tWorkOrderRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(
        () => mockDatabase.update(
          table: 'work_orders',
          values: tWorkOrderRequest.toJson(),
          filters: [SupabaseFilter.eq('id', tWorkOrderRequest.id)],
        ),
      ).called(1);
    });

    test('deleteWorkOrder should return SuccessState<bool>(true)', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tWorkOrderModel.toJson()]);

      final result = await dataSource.deleteWorkOrder(tWorkOrderId);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(
        () => mockDatabase.update(
          table: 'work_orders',
          values: any(named: 'values'),
          filters: [SupabaseFilter.eq('id', tWorkOrderId)],
        ),
      ).called(1);
    });
  });

  group('WorkOrdersRemoteDataSourceImpl - Tasks', () {
    test(
      'getTasksByWorkOrder should return SuccessState<List<TaskModel>>',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tTaskModel.toJson()]);

        final result = await dataSource.getTasksByWorkOrder(tWorkOrderId);

        expect(result, isA<SuccessState<List<TaskModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tTaskModel.id);
        verify(
          () => mockDatabase.selectList(
            table: 'tasks',
            filters: [
              SupabaseFilter.eq('work_order_id', tWorkOrderId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      },
    );

    test('createTask should return SuccessState<bool>(true)', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenAnswer((_) async => [tTaskModel.toJson()]);

      final result = await dataSource.createTask(tTaskRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(
        () =>
            mockDatabase.insert(table: 'tasks', values: tTaskRequest.toJson()),
      ).called(1);
    });

    test('updateTask should return SuccessState<bool>(true)', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tTaskModel.toJson()]);

      final result = await dataSource.updateTask(tTaskRequest);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(
        () => mockDatabase.update(
          table: 'tasks',
          values: tTaskRequest.toJson(),
          filters: [SupabaseFilter.eq('id', tTaskRequest.id)],
        ),
      ).called(1);
    });

    test('deleteTask should return SuccessState<bool>(true)', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => [tTaskModel.toJson()]);

      final result = await dataSource.deleteTask(tTaskId);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      verify(
        () => mockDatabase.update(
          table: 'tasks',
          values: any(named: 'values'),
          filters: [SupabaseFilter.eq('id', tTaskId)],
        ),
      ).called(1);
    });
  });

  group('WorkOrdersRemoteDataSourceImpl - Change Requests', () {
    test(
      'getChangeRequests should return SuccessState<List<WorkOrderChangeRequestModel>>',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tChangeModel.toJson()]);

        final result = await dataSource.getChangeRequests(tCompanyId);

        expect(result, isA<SuccessState<List<WorkOrderChangeRequestModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tChangeModel.id);
        verify(
          () => mockDatabase.selectList(
            table: 'work_order_change_requests',
            filters: [
              SupabaseFilter.eq('company_id', tCompanyId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      },
    );

    test(
      'createChangeRequest should return SuccessState<bool>(true)',
      () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tChangeModel.toJson()]);

        final result = await dataSource.createChangeRequest(tChangeRequest);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockDatabase.insert(
            table: 'work_order_change_requests',
            values: tChangeRequest.toJson(),
          ),
        ).called(1);
      },
    );

    test(
      'reviewChangeRequest should return SuccessState<bool>(true)',
      () async {
        final tStatus = faker.randomGenerator.element(['approved', 'rejected']);
        final tRejectionReason = faker.lorem.sentence();
        final tReviewerId = faker.guid.guid();

        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tChangeModel.toJson()]);

        final result = await dataSource.reviewChangeRequest(
          id: tChangeId,
          status: tStatus,
          rejectionReason: tRejectionReason,
          reviewedById: tReviewerId,
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockDatabase.update(
            table: 'work_order_change_requests',
            values: any(named: 'values'),
            filters: [SupabaseFilter.eq('id', tChangeId)],
          ),
        ).called(1);
      },
    );
  });

  group('WorkOrdersRemoteDataSourceImpl - History', () {
    test(
      'getWorkOrderHistory should return SuccessState<List<WorkOrderHistoryModel>>',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tHistoryModel.toJson()]);

        final result = await dataSource.getWorkOrderHistory(tWorkOrderId);

        expect(result, isA<SuccessState<List<WorkOrderHistoryModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tHistoryModel.id);
        verify(
          () => mockDatabase.selectList(
            table: 'work_order_history',
            filters: [SupabaseFilter.eq('work_order_id', tWorkOrderId)],
          ),
        ).called(1);
      },
    );
  });
}
