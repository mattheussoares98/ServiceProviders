import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/delete_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/restore_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_work_order_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_work_orders_realtime_use_case.dart';

@LazySingleton()
class WorkOrderDetailsCubitUseCases {
  const WorkOrderDetailsCubitUseCases({
    required this.getWorkOrderById,
    required this.updateWorkOrder,
    required this.deleteWorkOrder,
    required this.restoreWorkOrder,
    required this.cancelPause,
    required this.watchWorkOrdersRealtime,
    required this.getActiveCompanyId,
    required this.getSelectedMode,
    required this.getSessionUser,
    required this.getWorkOrderHistory,
    required this.createChangeRequest,
    required this.reviewChangeRequest,
  });

  final GetWorkOrderByIdUseCase getWorkOrderById;
  final UpdateWorkOrderUseCase updateWorkOrder;
  final DeleteWorkOrderUseCase deleteWorkOrder;
  final RestoreWorkOrderUseCase restoreWorkOrder;
  final CancelPauseUseCase cancelPause;
  final WatchWorkOrdersRealtimeUseCase watchWorkOrdersRealtime;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final GetSelectedModeUseCase getSelectedMode;
  final GetSessionUserUseCase getSessionUser;
  final GetWorkOrderHistoryUseCase getWorkOrderHistory;
  final CreateWorkOrderChangeRequestUseCase createChangeRequest;
  final ReviewWorkOrderChangeRequestUseCase reviewChangeRequest;
}
