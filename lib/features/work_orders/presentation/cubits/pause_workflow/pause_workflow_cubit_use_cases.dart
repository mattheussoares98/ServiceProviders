import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/has_permission_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_reasons_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/request_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_pause_use_case.dart';

@LazySingleton()
class PauseWorkflowCubitUseCases {
  const PauseWorkflowCubitUseCases({
    required this.requestPause,
    required this.reviewPause,
    required this.requestCompletion,
    required this.reviewCompletion,
    required this.getPauseReasons,
    required this.getPauseRequests,
    required this.getActiveCompanyId,
    required this.hasPermission,
    required this.getSessionUser,
  });
  final RequestPauseUseCase requestPause;
  final ReviewPauseUseCase reviewPause;
  final RequestCompletionUseCase requestCompletion;
  final ReviewCompletionUseCase reviewCompletion;
  final GetPauseReasonsUseCase getPauseReasons;
  final GetPauseRequestsUseCase getPauseRequests;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
  final HasPermissionUseCase hasPermission;
  final GetSessionUserUseCase getSessionUser;
}
