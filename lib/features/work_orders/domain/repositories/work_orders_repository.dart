import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/task_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';

abstract interface class WorkOrdersRepository {
  // Work Orders
  FutureList<WorkOrderEntity> getWorkOrders(String companyId);
  FutureData<WorkOrderEntity> getWorkOrderById(String id);
  FutureBool createWorkOrder(WorkOrderEntity workOrder);
  FutureBool updateWorkOrder(WorkOrderEntity workOrder);
  FutureBool deleteWorkOrder(String id);

  // Tasks (subtasks of a work order)
  FutureList<TaskEntity> getTasksByWorkOrder(String workOrderId);
  FutureBool createTask(TaskEntity task);
  FutureBool updateTask(TaskEntity task);
  FutureBool deleteTask(String id);

  // Change Requests
  FutureList<WorkOrderChangeRequestEntity> getChangeRequests(String companyId);
  FutureBool createChangeRequest(WorkOrderChangeRequestEntity request);
  FutureBool reviewChangeRequest({
    required String id,
    required ChangeRequestStatus status,
    String? rejectionReason,
    required String reviewedById,
  });

  // History
  FutureList<WorkOrderHistoryEntity> getWorkOrderHistory(String workOrderId);
}