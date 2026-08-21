import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_order.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

abstract interface class WorkOrdersRemoteDataSource {
  FutureList<WorkOrderModel> getWorkOrders(
    String companyId, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 50,
    int offset = 0,
  });
  FutureList<WorkOrderModel> getWorkOrdersDelta(
    String companyId, {
    required DateTime since,
    int limit = 100,
  });

  /// Provider mode. Spans every contracting company, so it is scoped by the
  /// provider companies the user belongs to instead of by `company_id`.
  FutureList<WorkOrderModel> getProviderWorkOrders(
    List<String> serviceProviderCompanyIds, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 50,
    int offset = 0,
  });
  FutureData<WorkOrderModel> getWorkOrderById(String id);
  FutureBool createWorkOrder(WorkOrderModel request);
  FutureBool updateWorkOrder(WorkOrderModel request);
  FutureBool deleteWorkOrder(String id);

  FutureList<TaskModel> getTasksByWorkOrder(String workOrderId);
  FutureBool createTask(TaskRequestModel request);
  FutureBool updateTask(TaskRequestModel request);
  FutureBool deleteTask(String id);

  FutureList<WorkOrderChangeRequestModel> getChangeRequests(String companyId);
  FutureBool createChangeRequest(WorkOrderChangeRequestRequestModel request);
  FutureBool reviewChangeRequest({
    required String id,
    required String status,
    String? rejectionReason,
    required String reviewedById,
  });

  FutureList<WorkOrderHistoryModel> getWorkOrderHistory(String workOrderId);
}

@LazySingleton(as: WorkOrdersRemoteDataSource)
final class WorkOrdersRemoteDataSourceImpl
    implements WorkOrdersRemoteDataSource {
  const WorkOrdersRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<WorkOrderModel> getWorkOrders(
    String companyId, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 50,
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
          filter.scheduledDateFrom!.toIsoUtcString(),
        ),
      if (filter.scheduledDateTo != null)
        SupabaseFilter.lte(
          'scheduled_date',
          filter.scheduledDateTo!.toIsoUtcString(),
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
    return response.map(WorkOrderModel.fromJson).toList();
  });

  @override
  FutureList<WorkOrderModel> getWorkOrdersDelta(
    String companyId, {
    required DateTime since,
    int limit = 100,
  }) => SupabaseHandler.call(() async {
    final filters = [
      SupabaseFilter.eq('company_id', companyId),
      SupabaseFilter.gt('updated_at', since.toIsoUtcString()),
    ];

    final response = await _database.selectList(
      table: 'work_orders',
      columns: '*, attachments(*)',
      filters: filters,
      orderBy: [const SupabaseOrder(column: 'updated_at', ascending: true)],
      limit: limit,
    );
    return response.map(WorkOrderModel.fromJson).toList();
  });

  @override
  FutureList<WorkOrderModel> getProviderWorkOrders(
    List<String> serviceProviderCompanyIds, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 50,
    int offset = 0,
  }) => SupabaseHandler.call(() async {
    if (serviceProviderCompanyIds.isEmpty) {
      return <WorkOrderModel>[];
    }

    // The filter's own company selection narrows the provider's memberships;
    // anything outside them is ignored so a stale selection cannot widen access.
    final selected = filter.serviceProviderCompanyIds
        .where(serviceProviderCompanyIds.contains)
        .toList();
    final scopedCompanyIds = selected.isEmpty
        ? serviceProviderCompanyIds
        : selected;

    final filters = [
      SupabaseFilter.inList('service_provider_company_id', scopedCompanyIds),
      SupabaseFilter.isFilter('deleted_at', null),
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
      if (filter.scheduledDateFrom != null)
        SupabaseFilter.gte(
          'scheduled_date',
          filter.scheduledDateFrom!.toIsoUtcString(),
        ),
      if (filter.scheduledDateTo != null)
        SupabaseFilter.lte(
          'scheduled_date',
          filter.scheduledDateTo!.toIsoUtcString(),
        ),
      if (filter.searchText != null && filter.searchText!.isNotEmpty)
        SupabaseFilter.ilike('title', '%${filter.searchText!}%'),
    ];

    final response = await _database.selectList(
      table: 'work_orders',
      columns: '*, attachments(*)',
      filters: filters,
      orderBy: [const SupabaseOrder(column: 'created_at')],
      limit: pageSize,
      offset: offset,
    );
    return response.map(WorkOrderModel.fromJson).toList();
  });

  @override
  FutureData<WorkOrderModel> getWorkOrderById(String id) =>
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
        return WorkOrderModel.fromJson(response);
      });

  @override
  FutureBool createWorkOrder(WorkOrderModel request) =>
      SupabaseHandler.call(() async {
        await _database.insert(table: 'work_orders', values: request.toJson());
        return true;
      });

  @override
  FutureBool updateWorkOrder(WorkOrderModel request) =>
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
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
    return true;
  });

  @override
  FutureList<TaskModel> getTasksByWorkOrder(String workOrderId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'tasks',
          filters: [
            SupabaseFilter.eq('work_order_id', workOrderId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(TaskModel.fromJson).toList();
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
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
    return true;
  });

  @override
  FutureList<WorkOrderChangeRequestModel> getChangeRequests(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'work_order_change_requests',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(WorkOrderChangeRequestModel.fromJson).toList();
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
        'updated_at': DateTime.now().toIsoUtcString(),
      },
      filters: [SupabaseFilter.eq('id', id)],
    );
    return true;
  });

  @override
  FutureList<WorkOrderHistoryModel> getWorkOrderHistory(String workOrderId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'work_order_history',
          filters: [SupabaseFilter.eq('work_order_id', workOrderId)],
        );
        return response.map(WorkOrderHistoryModel.fromJson).toList();
      });
}

final class _NotFoundException implements Exception {
  const _NotFoundException(this.message);
  final String message;
  @override
  String toString() => message;
}
