import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_log_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/task_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

abstract interface class WorkOrdersRepository {
  // Work Orders
  FutureList<WorkOrderEntity> getWorkOrders(
    String companyId, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 50,
    int offset = 0,
  });

  /// Provider mode. Online-only (V2 §1.4) — no Drift fallback, because the
  /// local database is scoped to a single contracting company.
  FutureList<WorkOrderEntity> getProviderWorkOrders(
    List<String> serviceProviderCompanyIds, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 50,
    int offset = 0,
  });
  FutureData<WorkOrderEntity> getWorkOrderById(String id);
  FutureBool createWorkOrder(WorkOrderEntity workOrder);
  FutureBool updateWorkOrder(WorkOrderEntity workOrder);
  FutureBool deleteWorkOrder(String id);
  FutureBool restoreWorkOrder(String id);
  FutureBool hardDeleteWorkOrder(String id);
  FutureBool syncWorkOrders(String companyId);

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
  FutureList<AuditLogEntity> getWorkOrderHistory(String workOrderId);

  // Realtime
  Stream<RealtimeEvent<WorkOrderEntity>> watchRealtimeWorkOrders({
    String? companyId,
  });
}
