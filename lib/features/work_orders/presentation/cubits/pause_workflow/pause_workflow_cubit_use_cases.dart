import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
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
    required this.cancelPause,
    required this.reviewPause,
    required this.requestCompletion,
    required this.reviewCompletion,
    required this.getPauseReasons,
    required this.getPauseRequests,
    required this.getSectors,
    required this.getActiveCompanyId,
  });
  final RequestPauseUseCase requestPause;
  final CancelPauseUseCase cancelPause;
  final ReviewPauseUseCase reviewPause;
  final RequestCompletionUseCase requestCompletion;
  final ReviewCompletionUseCase reviewCompletion;
  final GetPauseReasonsUseCase getPauseReasons;
  final GetPauseRequestsUseCase getPauseRequests;
  final GetSectorsUseCase getSectors;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
}
