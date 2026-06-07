import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_type.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_type.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

abstract interface class WorkOrdersLocalDataSource {
  // Work Orders
  FutureList<WorkOrderResponseModel> getWorkOrders(String companyId);
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id);
  FutureBool saveWorkOrder(WorkOrderResponseModel workOrder);
  FutureBool deleteWorkOrder(String id);

  // Tasks
  FutureList<TaskResponseModel> getTasksByWorkOrder(String workOrderId);
  FutureBool saveTask(TaskResponseModel task);
  FutureBool deleteTask(String id);

  // Change Requests
  FutureList<WorkOrderChangeRequestResponseModel> getChangeRequests(String companyId);
  FutureBool saveChangeRequest(WorkOrderChangeRequestResponseModel request);
  FutureBool reviewChangeRequest({
    required String id,
    required String status,
    String? rejectionReason,
    required String reviewedById,
  });

  // History
  FutureList<WorkOrderHistoryResponseModel> getWorkOrderHistory(String workOrderId);
  FutureBool saveWorkOrderHistory(WorkOrderHistoryResponseModel history);
}

@LazySingleton(as: WorkOrdersLocalDataSource)
final class WorkOrdersLocalDataSourceImpl implements WorkOrdersLocalDataSource {
  WorkOrdersLocalDataSourceImpl({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;

  // ============================================
  // Work Orders
  // ============================================

  @override
  FutureList<WorkOrderResponseModel> getWorkOrders(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrders)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map((row) => WorkOrderResponseModel(
                id: row.id,
                companyId: row.companyId,
                assetId: row.assetId,
                locationId: row.locationId,
                assignedToId: row.assignedToId,
                createdById: row.createdById,
                maintenancePlanId: row.maintenancePlanId,
                title: row.title,
                description: row.description,
                priority: Priority.fromCode(row.priority),
                status: WorkOrderStatus.fromCode(row.status),
                type: WorkOrderType.fromCode(row.type),
                scheduledDate: row.scheduledDate,
                startedAt: row.startedAt,
                completedAt: row.completedAt,
                estimatedDuration: row.estimatedDuration,
                actualDuration: row.actualDuration,
                laborCost: row.laborCost,
                partsCost: row.partsCost,
                totalCost: row.totalCost,
                notes: row.notes,
                createdAt: row.createdAt,
                updatedAt: row.updatedAt,
                deletedAt: row.deletedAt,
              ))
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrders)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
      final row = await query.getSingleOrNull();

      if (row == null) {
        return FailureState(message: 'Work order not found');
      }

      final model = WorkOrderResponseModel(
        id: row.id,
        companyId: row.companyId,
        assetId: row.assetId,
        locationId: row.locationId,
        assignedToId: row.assignedToId,
        createdById: row.createdById,
        maintenancePlanId: row.maintenancePlanId,
        title: row.title,
        description: row.description,
        priority: Priority.fromCode(row.priority),
        status: WorkOrderStatus.fromCode(row.status),
        type: WorkOrderType.fromCode(row.type),
        scheduledDate: row.scheduledDate,
        startedAt: row.startedAt,
        completedAt: row.completedAt,
        estimatedDuration: row.estimatedDuration,
        actualDuration: row.actualDuration,
        laborCost: row.laborCost,
        partsCost: row.partsCost,
        totalCost: row.totalCost,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );

      return SuccessState(data: model);
    });
  }

  @override
  FutureBool saveWorkOrder(WorkOrderResponseModel workOrder) {
    return ErrorHandler.execute(() async {
      await _database.into(_database.workOrders).insertOnConflictUpdate(
            WorkOrdersCompanion(
              id: Value(workOrder.id),
              companyId: Value(workOrder.companyId),
              assetId: Value(workOrder.assetId),
              locationId: Value(workOrder.locationId),
              assignedToId: Value(workOrder.assignedToId),
              createdById: Value(workOrder.createdById),
              maintenancePlanId: Value(workOrder.maintenancePlanId),
              title: Value(workOrder.title),
              description: Value(workOrder.description),
              priority: Value(workOrder.priority.code),
              status: Value(workOrder.status.code),
              type: Value(workOrder.type.code),
              scheduledDate: Value(workOrder.scheduledDate),
              startedAt: Value(workOrder.startedAt),
              completedAt: Value(workOrder.completedAt),
              estimatedDuration: Value(workOrder.estimatedDuration),
              actualDuration: Value(workOrder.actualDuration),
              laborCost: Value(workOrder.laborCost),
              partsCost: Value(workOrder.partsCost),
              totalCost: Value(workOrder.totalCost),
              notes: Value(workOrder.notes),
              createdAt: Value(workOrder.createdAt),
              updatedAt: Value(workOrder.updatedAt),
              deletedAt: Value(workOrder.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteWorkOrder(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.workOrders)
        ..where((t) => t.id.equals(id));
      await query.write(
        WorkOrdersCompanion(
          deletedAt: Value(DateTime.now()),
        ),
      );
      return const SuccessState(data: true);
    });
  }

  // ============================================
  // Tasks
  // ============================================

  @override
  FutureList<TaskResponseModel> getTasksByWorkOrder(String workOrderId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.tasks)
        ..where((t) => t.workOrderId.equals(workOrderId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map((row) => TaskResponseModel(
                id: row.id,
                workOrderId: row.workOrderId,
                companyId: row.companyId,
                title: row.title,
                description: row.description,
                isCompleted: row.isCompleted,
                completedAt: row.completedAt,
                completedById: row.completedById,
                sortOrder: row.sortOrder,
                createdAt: row.createdAt,
                updatedAt: row.updatedAt,
                deletedAt: row.deletedAt,
              ))
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveTask(TaskResponseModel task) {
    return ErrorHandler.execute(() async {
      await _database.into(_database.tasks).insertOnConflictUpdate(
            TasksCompanion(
              id: Value(task.id),
              workOrderId: Value(task.workOrderId),
              companyId: Value(task.companyId),
              title: Value(task.title),
              description: Value(task.description),
              isCompleted: Value(task.isCompleted),
              completedAt: Value(task.completedAt),
              completedById: Value(task.completedById),
              sortOrder: Value(task.sortOrder),
              createdAt: Value(task.createdAt),
              updatedAt: Value(task.updatedAt),
              deletedAt: Value(task.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteTask(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.tasks)
        ..where((t) => t.id.equals(id));
      await query.write(
        TasksCompanion(
          deletedAt: Value(DateTime.now()),
        ),
      );
      return const SuccessState(data: true);
    });
  }

  // ============================================
  // Change Requests
  // ============================================

  @override
  FutureList<WorkOrderChangeRequestResponseModel> getChangeRequests(String companyId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrderChangeRequests)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map((row) => WorkOrderChangeRequestResponseModel(
                id: row.id,
                workOrderId: row.workOrderId,
                companyId: row.companyId,
                requestedById: row.requestedById,
                changeType: WorkOrderChangeType.fromCode(row.changeType),
                changeData: row.changeData,
                status: ChangeRequestStatus.fromCode(row.status),
                reviewedById: row.reviewedById,
                rejectionReason: row.rejectionReason,
                createdAt: row.createdAt,
                updatedAt: row.updatedAt,
                deletedAt: row.deletedAt,
              ))
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveChangeRequest(WorkOrderChangeRequestResponseModel request) {
    return ErrorHandler.execute(() async {
      await _database.into(_database.workOrderChangeRequests).insertOnConflictUpdate(
            WorkOrderChangeRequestsCompanion(
              id: Value(request.id),
              workOrderId: Value(request.workOrderId),
              companyId: Value(request.companyId),
              requestedById: Value(request.requestedById),
              changeType: Value(request.changeType.code),
              changeData: Value(request.changeData),
              status: Value(request.status.code),
              reviewedById: Value(request.reviewedById),
              rejectionReason: Value(request.rejectionReason),
              createdAt: Value(request.createdAt),
              updatedAt: Value(request.updatedAt),
              deletedAt: Value(request.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool reviewChangeRequest({
    required String id,
    required String status,
    String? rejectionReason,
    required String reviewedById,
  }) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.workOrderChangeRequests)
        ..where((t) => t.id.equals(id));
      await query.write(
        WorkOrderChangeRequestsCompanion(
          status: Value(status),
          rejectionReason: Value(rejectionReason),
          reviewedById: Value(reviewedById),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return const SuccessState(data: true);
    });
  }


  // ============================================
  // History
  // ============================================

  @override
  FutureList<WorkOrderHistoryResponseModel> getWorkOrderHistory(String workOrderId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrderHistory)
        ..where((t) => t.workOrderId.equals(workOrderId));
      final rows = await query.get();

      final list = rows
          .map((row) => WorkOrderHistoryResponseModel(
                id: row.id,
                workOrderId: row.workOrderId,
                companyId: row.companyId,
                userId: row.userId,
                action: row.action,
                oldValue: row.oldValue,
                newValue: row.newValue,
                createdAt: row.createdAt,
              ))
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveWorkOrderHistory(WorkOrderHistoryResponseModel history) {
    return ErrorHandler.execute(() async {
      await _database.into(_database.workOrderHistory).insertOnConflictUpdate(
            WorkOrderHistoryCompanion(
              id: Value(history.id),
              workOrderId: Value(history.workOrderId),
              companyId: Value(history.companyId),
              userId: Value(history.userId),
              action: Value(history.action),
              oldValue: Value(history.oldValue),
              newValue: Value(history.newValue),
              createdAt: Value(history.createdAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }
}
