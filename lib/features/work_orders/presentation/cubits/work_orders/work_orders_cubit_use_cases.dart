import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/create_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/delete_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/get_attachments_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/upload_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_companies_by_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_session_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/sync/domain/services/sync_engine.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_provider_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_change_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/sync_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_work_orders_realtime_use_case.dart';

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
    required this.syncEngine,
    required this.watchWorkOrdersRealtime,
    required this.getProviderWorkOrders,
    required this.getServiceProviderProfilesByAuthUser,
    required this.getSessionProviderProfile,
    required this.getServiceProviderCompaniesByIds,
    required this.getSessionUser,
    required this.getSelectedMode,
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
  final SyncEngine syncEngine;
  final WatchWorkOrdersRealtimeUseCase watchWorkOrdersRealtime;

  // Provider mode
  final GetProviderWorkOrdersUseCase getProviderWorkOrders;
  final GetSessionProviderProfileUseCase getSessionProviderProfile;
  final GetServiceProviderProfilesByAuthUserUseCase
  getServiceProviderProfilesByAuthUser;
  final GetServiceProviderCompaniesByIdsUseCase
  getServiceProviderCompaniesByIds;
  final GetSessionUserUseCase getSessionUser;
  final GetSelectedModeUseCase getSelectedMode;
}
