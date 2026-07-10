import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/upload_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_change_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_work_order_use_case.dart';

@LazySingleton()
class WorkOrdersCubitUseCases {
  const WorkOrdersCubitUseCases({
    required this.getSessionUser,
    required this.getWorkOrders,
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
  });

  final GetSessionUserUseCase getSessionUser;
  final GetWorkOrdersUseCase getWorkOrders;
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
}
