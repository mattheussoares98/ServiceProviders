import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/data/handlers/supabase_handler.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/work_order_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:injectable/injectable.dart';

abstract interface class WorkOrdersRemoteDataSource {
  FutureList<WorkOrderResponseModel> getWorkOrders(String companyId);
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id);
  FutureBool createWorkOrder(WorkOrderRequestModel request);
  FutureBool updateWorkOrder(WorkOrderRequestModel request);
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
  FutureList<WorkOrderResponseModel> getWorkOrders(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'work_orders',
          filters: [SupabaseFilter.eq('company_id', companyId)],
        );
        return response.map(WorkOrderResponseModel.fromJson).toList();
      });

  @override
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectOne(
          table: 'work_orders',
          filters: [SupabaseFilter.eq('id', id)],
        );
        if (response == null) {
          throw _NotFoundException(
            'Ordem de serviço não encontrada.'.hardcoded,
          );
        }
        return WorkOrderResponseModel.fromJson(response);
      });

  @override
  FutureBool createWorkOrder(WorkOrderRequestModel request) =>
      SupabaseHandler.call(() async {
        await _database.insert(table: 'work_orders', values: request.toJson());
        return true;
      });

  @override
  FutureBool updateWorkOrder(WorkOrderRequestModel request) =>
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
          filters: [SupabaseFilter.eq('work_order_id', workOrderId)],
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
      filters: [SupabaseFilter.eq('company_id', companyId)],
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
