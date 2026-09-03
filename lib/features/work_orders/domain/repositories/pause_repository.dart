import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_responsability.dart';

abstract interface class PauseRepository {
  FutureList<PauseReasonEntity> getPauseReasons(String companyId);
  FutureList<PauseRequestEntity> getPauseRequests(
    String workOrderId, {
    PauseRequestStatus? status,
  });
  FutureBool requestPause(PauseRequestEntity pauseRequest);
  FutureBool reviewPause({
    required String id,
    required String workOrderId,
    required PauseRequestStatus status,
    String? reviewObservation,
    required String reviewedById,
    String? reasonId,
    PauseResponsibility? responsibility,
  });
  FutureBool reviewCompletion({
    required String id,
    required String workOrderId,
    required PauseRequestStatus status,
    required String reviewedById,
    String? reviewObservation,
    PauseResponsibility? responsibility,
    String? completionReason,
    String? completionSectorId,
  });
  FutureBool cancelPause({
    required String id,
    required String workOrderId,
    required DateTime resumedAt,
    required String resumedById,
  });
}
