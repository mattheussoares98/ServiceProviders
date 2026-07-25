import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

abstract interface class WorkOrdersLocalDataSource {
  // Work Orders
  FutureList<WorkOrderResponseModel> getWorkOrders(
    String companyId, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 20,
    int offset = 0,
  });
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id);
  FutureBool saveWorkOrder(WorkOrderResponseModel workOrder);
  FutureBool deleteWorkOrder(String id);

  // Tasks
  FutureList<TaskResponseModel> getTasksByWorkOrder(String workOrderId);
  FutureBool saveTask(TaskResponseModel task);
  FutureBool deleteTask(String id);

  // Change Requests
  FutureList<WorkOrderChangeRequestResponseModel> getChangeRequests(
    String companyId,
  );
  FutureBool saveChangeRequest(WorkOrderChangeRequestResponseModel request);
  FutureBool reviewChangeRequest({
    required String id,
    required String status,
    String? rejectionReason,
    required String reviewedById,
  });

  // History
  FutureList<WorkOrderHistoryResponseModel> getWorkOrderHistory(
    String workOrderId,
  );
  FutureBool saveWorkOrderHistory(WorkOrderHistoryResponseModel history);
}

@LazySingleton(as: WorkOrdersLocalDataSource)
final class WorkOrdersLocalDataSourceImpl implements WorkOrdersLocalDataSource {
  WorkOrdersLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  // ============================================
  // Work Orders
  // ============================================

  @override
  FutureList<WorkOrderResponseModel> getWorkOrders(
    String companyId, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 20,
    int offset = 0,
  }) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrders).join([
        innerJoin(
          _database.locations,
          _database.locations.id.equalsExp(_database.workOrders.locationId),
        ),
      ]);

      // Base conditions
      var condition =
          _database.workOrders.companyId.equals(companyId) &
          _database.workOrders.deletedAt.isNull() &
          _database.locations.deletedAt.isNull();

      // Apply filters
      if (filter.statuses.isNotEmpty) {
        condition =
            condition &
            _database.workOrders.status.isIn(
              filter.statuses.map((s) => s.code).toList(),
            );
      }
      if (filter.priorities.isNotEmpty) {
        condition =
            condition &
            _database.workOrders.priority.isIn(
              filter.priorities.map((p) => p.code).toList(),
            );
      }
      if (filter.type != null) {
        condition =
            condition & _database.workOrders.type.equals(filter.type!.code);
      }
      if (filter.assignedToId != null) {
        condition =
            condition &
            _database.workOrders.assignedToId.equals(filter.assignedToId!);
      }
      if (filter.scheduledDateFrom != null) {
        condition =
            condition &
            _database.workOrders.scheduledDate.isBiggerOrEqualValue(
              filter.scheduledDateFrom!,
            );
      }
      if (filter.scheduledDateTo != null) {
        condition =
            condition &
            _database.workOrders.scheduledDate.isSmallerOrEqualValue(
              filter.scheduledDateTo!,
            );
      }
      if (filter.searchText != null && filter.searchText!.isNotEmpty) {
        condition =
            condition &
            _database.workOrders.title.like('%${filter.searchText!}%');
      }

      // The 'offset' determines how many rows to skip before fetching.
      // E.g., offset = 0 gets the first page, offset = 20 skips 20 and gets the second page.
      query
        ..where(condition)
        ..orderBy([OrderingTerm.desc(_database.workOrders.createdAt)])
        ..limit(pageSize, offset: offset);

      final rows = await query.get();

      final orderIds = rows
          .map((row) => row.readTable(_database.workOrders).id)
          .toList();

      final attachmentsQuery = _database.select(_database.attachments)
        ..where((t) => t.workOrderId.isIn(orderIds) & t.deletedAt.isNull());
      final attachmentsRows = await attachmentsQuery.get();

      final attachmentsByWorkOrder = <String, List<AttachmentResponseModel>>{};
      for (final row in attachmentsRows) {
        final attachment = AttachmentResponseModel(
          id: row.id,
          workOrderId: row.workOrderId,
          companyId: row.companyId,
          uploadedById: row.uploadedById,
          fileName: row.fileName,
          fileType: FileType.fromCode(row.fileType),
          localPath: row.localPath,
          remoteUrl: row.remoteUrl,
          fileSizeBytes: row.fileSizeBytes,
          isCompressed: row.isCompressed,
          uploadStatus: UploadStatus.fromCode(row.uploadStatus),
          createdAt: row.createdAt,
          deletedAt: row.deletedAt,
          originalPath: row.originalPath,
        );
        attachmentsByWorkOrder
            .putIfAbsent(row.workOrderId, () => [])
            .add(attachment);
      }

      final list = rows.map((row) {
        final order = row.readTable(_database.workOrders);
        return WorkOrderResponseModel(
          id: order.id,
          companyId: order.companyId,
          assetId: order.assetId,
          locationId: order.locationId,
          assignedToId: order.assignedToId,
          createdById: order.createdById,
          maintenancePlanId: order.maintenancePlanId,
          title: order.title,
          description: order.description,
          priority: Priority.fromCode(order.priority),
          status: WorkOrderStatus.fromCode(order.status),
          type: WorkOrderType.fromCode(order.type),
          scheduledDate: order.scheduledDate,
          startedAt: order.startedAt,
          completedAt: order.completedAt,
          estimatedDuration: order.estimatedDuration,
          actualDuration: order.actualDuration,
          laborCost: order.laborCost,
          partsCost: order.partsCost,
          totalCost: order.totalCost,
          notes: order.notes,
          createdAt: order.createdAt,
          updatedAt: order.updatedAt,
          deletedAt: order.deletedAt,
          attachments: attachmentsByWorkOrder[order.id] ?? const [],
          completionReason: order.completionReason,
          completionResponsibility: order.completionResponsibility != null
              ? PauseResponsibility.fromValue(order.completionResponsibility!)
              : null,
          completionSectorId: order.completionSectorId,
        );
      }).toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id) {
    return ErrorHandler.execute(() async {
      final query =
          _database.select(_database.workOrders).join([
            innerJoin(
              _database.locations,
              _database.locations.id.equalsExp(_database.workOrders.locationId),
            ),
          ])..where(
            _database.workOrders.id.equals(id) &
                _database.workOrders.deletedAt.isNull() &
                _database.locations.deletedAt.isNull(),
          );
      final row = await query.getSingleOrNull();

      if (row == null) {
        return FailureState(message: 'Work order not found');
      }

      final attachmentsQuery = _database.select(_database.attachments)
        ..where((t) => t.workOrderId.equals(id) & t.deletedAt.isNull());
      final attachmentsRows = await attachmentsQuery.get();
      final attachments = attachmentsRows
          .map(
            (t) => AttachmentResponseModel(
              id: t.id,
              workOrderId: t.workOrderId,
              companyId: t.companyId,
              uploadedById: t.uploadedById,
              fileName: t.fileName,
              fileType: FileType.fromCode(t.fileType),
              localPath: t.localPath,
              remoteUrl: t.remoteUrl,
              fileSizeBytes: t.fileSizeBytes,
              isCompressed: t.isCompressed,
              uploadStatus: UploadStatus.fromCode(t.uploadStatus),
              createdAt: t.createdAt,
              deletedAt: t.deletedAt,
              originalPath: t.originalPath,
            ),
          )
          .toList();

      final order = row.readTable(_database.workOrders);
      final model = WorkOrderResponseModel(
        id: order.id,
        companyId: order.companyId,
        assetId: order.assetId,
        locationId: order.locationId,
        assignedToId: order.assignedToId,
        createdById: order.createdById,
        maintenancePlanId: order.maintenancePlanId,
        title: order.title,
        description: order.description,
        priority: Priority.fromCode(order.priority),
        status: WorkOrderStatus.fromCode(order.status),
        type: WorkOrderType.fromCode(order.type),
        scheduledDate: order.scheduledDate,
        startedAt: order.startedAt,
        completedAt: order.completedAt,
        estimatedDuration: order.estimatedDuration,
        actualDuration: order.actualDuration,
        laborCost: order.laborCost,
        partsCost: order.partsCost,
        totalCost: order.totalCost,
        notes: order.notes,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
        deletedAt: order.deletedAt,
        attachments: attachments,
        completionReason: order.completionReason,
        completionResponsibility: order.completionResponsibility != null
            ? PauseResponsibility.fromValue(order.completionResponsibility!)
            : null,
        completionSectorId: order.completionSectorId,
      );

      return SuccessState(data: model);
    });
  }

  @override
  FutureBool saveWorkOrder(WorkOrderResponseModel workOrder) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.workOrders)
          .insertOnConflictUpdate(
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
              completionReason: Value(workOrder.completionReason),
              completionResponsibility: Value(
                workOrder.completionResponsibility?.value,
              ),
              completionSectorId: Value(workOrder.completionSectorId),
            ),
          );

      for (final attachment in workOrder.attachments) {
        await _database
            .into(_database.attachments)
            .insertOnConflictUpdate(
              AttachmentsCompanion(
                id: Value(attachment.id),
                workOrderId: Value(attachment.workOrderId),
                companyId: Value(attachment.companyId),
                uploadedById: Value(attachment.uploadedById),
                fileName: Value(attachment.fileName),
                fileType: Value(attachment.fileType.code),
                localPath: Value(attachment.localPath),
                remoteUrl: Value(attachment.remoteUrl),
                fileSizeBytes: Value(attachment.fileSizeBytes),
                isCompressed: Value(attachment.isCompressed),
                uploadStatus: Value(attachment.uploadStatus.code),
                createdAt: Value(attachment.createdAt),
                deletedAt: Value(attachment.deletedAt),
                originalPath: Value(attachment.originalPath),
              ),
            );
      }

      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool deleteWorkOrder(String id) {
    return ErrorHandler.execute(() async {
      final query = _database.update(_database.workOrders)
        ..where((t) => t.id.equals(id));
      await query.write(WorkOrdersCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }

  // ============================================
  // Tasks
  // ============================================

  @override
  FutureList<TaskResponseModel> getTasksByWorkOrder(String workOrderId) {
    return ErrorHandler.execute(() async {
      final query = _database.select(
        _database.tasks,
      )..where((t) => t.workOrderId.equals(workOrderId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map(
            (row) => TaskResponseModel(
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
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveTask(TaskResponseModel task) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.tasks)
          .insertOnConflictUpdate(
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
      await query.write(TasksCompanion(deletedAt: Value(DateTime.now())));
      return const SuccessState(data: true);
    });
  }

  // ============================================
  // Change Requests
  // ============================================

  @override
  FutureList<WorkOrderChangeRequestResponseModel> getChangeRequests(
    String companyId,
  ) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrderChangeRequests)
        ..where((t) => t.companyId.equals(companyId) & t.deletedAt.isNull());
      final rows = await query.get();

      final list = rows
          .map(
            (row) => WorkOrderChangeRequestResponseModel(
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
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveChangeRequest(WorkOrderChangeRequestResponseModel request) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.workOrderChangeRequests)
          .insertOnConflictUpdate(
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
  FutureList<WorkOrderHistoryResponseModel> getWorkOrderHistory(
    String workOrderId,
  ) {
    return ErrorHandler.execute(() async {
      final query = _database.select(_database.workOrderHistory)
        ..where((t) => t.workOrderId.equals(workOrderId));
      final rows = await query.get();

      final list = rows
          .map(
            (row) => WorkOrderHistoryResponseModel(
              id: row.id,
              workOrderId: row.workOrderId,
              companyId: row.companyId,
              userId: row.userId,
              action: row.action,
              oldValue: row.oldValue,
              newValue: row.newValue,
              createdAt: row.createdAt,
            ),
          )
          .toList();

      return SuccessState(data: list);
    });
  }

  @override
  FutureBool saveWorkOrderHistory(WorkOrderHistoryResponseModel history) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.workOrderHistory)
          .insertOnConflictUpdate(
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
