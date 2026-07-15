import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_order.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

abstract interface class WorkOrdersRemoteDataSource {
  FutureList<WorkOrderResponseModel> getWorkOrders(
    String companyId, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 20,
    int offset = 0,
  });
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id);
  FutureBool createWorkOrder(WorkOrderResponseModel request);
  FutureBool updateWorkOrder(WorkOrderResponseModel request);
  FutureBool deleteWorkOrder(String id);

  FutureList<TaskResponseModel> getTasksByWorkOrder(String workOrderId);
  FutureBool createTask(TaskRequestModel request);
  FutureBool updateTask(TaskRequestModel request);
  FutureBool deleteTask(String id);

  FutureList<WorkOrderChangeRequestResponseModel> getChangeRequests(
    String companyId,
  );
  FutureBool createChangeRequest(WorkOrderChangeRequestRequestModel request);
  FutureBool reviewChangeRequest({
    required String id,
    required String status,
    String? rejectionReason,
    required String reviewedById,
  });

  FutureList<WorkOrderHistoryResponseModel> getWorkOrderHistory(
    String workOrderId,
  );
}

@LazySingleton(as: WorkOrdersRemoteDataSource)
final class WorkOrdersRemoteDataSourceImpl
    implements WorkOrdersRemoteDataSource {
  const WorkOrdersRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<WorkOrderResponseModel> getWorkOrders(
    String companyId, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 20,
    int offset = 0,
  }) => SupabaseHandler.call(() async {
    final filters = [
      SupabaseFilter.eq('company_id', companyId),
      SupabaseFilter.isFilter('deleted_at', null),
      SupabaseFilter.isFilter('locations.deleted_at', null),
      if (filter.statuses.isNotEmpty)
        SupabaseFilter.inList(
          'status',
          filter.statuses.map((s) => s.code).toList(),
        ),
      if (filter.priorities.isNotEmpty)
        SupabaseFilter.inList(
          'priority',
          filter.priorities.map((p) => p.code).toList(),
        ),
      if (filter.type != null) SupabaseFilter.eq('type', filter.type!.code),
      if (filter.assignedToId != null)
        SupabaseFilter.eq('assigned_to_id', filter.assignedToId!),
      if (filter.scheduledDateFrom != null)
        SupabaseFilter.gte(
          'scheduled_date',
          filter.scheduledDateFrom!.toIso8601String(),
        ),
      if (filter.scheduledDateTo != null)
        SupabaseFilter.lte(
          'scheduled_date',
          filter.scheduledDateTo!.toIso8601String(),
        ),
      if (filter.searchText != null && filter.searchText!.isNotEmpty)
        SupabaseFilter.ilike('title', '%${filter.searchText!}%'),
    ];

    final response = await _database.selectList(
      table: 'work_orders',
      columns: '*, locations!inner(deleted_at), attachments(*)',
      filters: filters,
      orderBy: [const SupabaseOrder(column: 'created_at')],
      limit: pageSize,
      offset: offset,
    );
    return response.map(WorkOrderResponseModel.fromJson).toList();
  });

  @override
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectOne(
          table: 'work_orders',
          columns: '*, locations!inner(deleted_at), attachments(*)',
          filters: [
            SupabaseFilter.eq('id', id),
            SupabaseFilter.isFilter('deleted_at', null),
            SupabaseFilter.isFilter('locations.deleted_at', null),
          ],
        );
        if (response == null) {
          throw _NotFoundException(
            'Ordem de serviço não encontrada.'.hardcoded,
          );
        }
        return WorkOrderResponseModel.fromJson(response);
      });

  @override
  FutureBool createWorkOrder(WorkOrderResponseModel request) =>
      SupabaseHandler.call(() async {
        await _database.insert(table: 'work_orders', values: request.toJson());
        return true;
      });

  @override
  FutureBool updateWorkOrder(WorkOrderResponseModel request) =>
      SupabaseHandler.call(() async {
        await _database.update(
          table: 'work_orders',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return true;
      });

  @override
  FutureBool deleteWorkOrder(String id) => SupabaseHandler.call(() async {
    await _database.update(
      table: 'work_orders',
      values: {'deleted_at': DateTime.now().toIso8601String()},
      filters: [SupabaseFilter.eq('id', id)],
    );
    return true;
  });

  @override
  FutureList<TaskResponseModel> getTasksByWorkOrder(String workOrderId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'tasks',
          filters: [
            SupabaseFilter.eq('work_order_id', workOrderId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(TaskResponseModel.fromJson).toList();
      });

  @override
  FutureBool createTask(TaskRequestModel request) =>
      SupabaseHandler.call(() async {
        await _database.insert(table: 'tasks', values: request.toJson());
        return true;
      });

  @override
  FutureBool updateTask(TaskRequestModel request) =>
      SupabaseHandler.call(() async {
        await _database.update(
          table: 'tasks',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return true;
      });

  @override
  FutureBool deleteTask(String id) => SupabaseHandler.call(() async {
    await _database.update(
      table: 'tasks',
      values: {'deleted_at': DateTime.now().toIso8601String()},
      filters: [SupabaseFilter.eq('id', id)],
    );
    return true;
  });

  @override
  FutureList<WorkOrderChangeRequestResponseModel> getChangeRequests(
    String companyId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'work_order_change_requests',
      filters: [
        SupabaseFilter.eq('company_id', companyId),
        SupabaseFilter.isFilter('deleted_at', null),
      ],
    );
    return response.map(WorkOrderChangeRequestResponseModel.fromJson).toList();
  });

  @override
  FutureBool createChangeRequest(WorkOrderChangeRequestRequestModel request) =>
      SupabaseHandler.call(() async {
        await _database.insert(
          table: 'work_order_change_requests',
          values: request.toJson(),
        );
        return true;
      });

  @override
  FutureBool reviewChangeRequest({
    required String id,
    required String status,
    String? rejectionReason,
    required String reviewedById,
  }) => SupabaseHandler.call(() async {
    await _database.update(
      table: 'work_order_change_requests',
      values: {
        'status': status,
        'rejection_reason': rejectionReason,
        'reviewed_by_id': reviewedById,
        'updated_at': DateTime.now().toIso8601String(),
      },
      filters: [SupabaseFilter.eq('id', id)],
    );
    return true;
  });

  @override
  FutureList<WorkOrderHistoryResponseModel> getWorkOrderHistory(
    String workOrderId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'work_order_history',
      filters: [SupabaseFilter.eq('work_order_id', workOrderId)],
    );
    return response.map(WorkOrderHistoryResponseModel.fromJson).toList();
  });
}

final class _NotFoundException implements Exception {
  const _NotFoundException(this.message);
  final String message;
  @override
  String toString() => message;
}
