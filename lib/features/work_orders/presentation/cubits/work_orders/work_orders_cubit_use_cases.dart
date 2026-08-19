import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/create_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/upload_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_change_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/sync_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_work_order_use_case.dart';

@LazySingleton()
class WorkOrdersCubitUseCases {
  const WorkOrdersCubitUseCases({
    required this.getActiveCompanyId,
    required this.getWorkOrders,
    required this.getWorkOrderById,
    required this.createWorkOrder,
    required this.updateWorkOrder,
    required this.deleteWorkOrder,
    required this.getChangeRequests,
    required this.createChangeRequest,
    required this.reviewChangeRequest,
    required this.getWorkOrderHistory,
    required this.getAttachments,
    required this.uploadAttachment,
    required this.deleteAttachment,
    required this.createAttachment,
    required this.cancelPause,
    required this.syncWorkOrders,
  });

  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetWorkOrdersUseCase getWorkOrders;
  final GetWorkOrderByIdUseCase getWorkOrderById;
  final CreateWorkOrderUseCase createWorkOrder;
  final UpdateWorkOrderUseCase updateWorkOrder;
  final DeleteWorkOrderUseCase deleteWorkOrder;
  final GetWorkOrderChangeRequestsUseCase getChangeRequests;
  final CreateWorkOrderChangeRequestUseCase createChangeRequest;
  final ReviewWorkOrderChangeRequestUseCase reviewChangeRequest;
  final GetWorkOrderHistoryUseCase getWorkOrderHistory;
  final GetAttachmentsUseCase getAttachments;
  final UploadAttachmentUseCase uploadAttachment;
  final DeleteAttachmentUseCase deleteAttachment;
  final CreateAttachmentUseCase createAttachment;
  final CancelPauseUseCase cancelPause;
  final SyncWorkOrdersUseCase syncWorkOrders;
}

