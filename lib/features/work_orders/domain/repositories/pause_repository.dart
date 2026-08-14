import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';

abstract interface class PauseRepository {
  FutureList<PauseReasonEntity> getPauseReasons(String companyId);
  FutureList<PauseRequestEntity> getPauseRequests(String workOrderId);
  FutureBool requestPause(PauseRequestEntity pauseRequest);
  FutureBool reviewPause({
    required String id,
    required PauseRequestStatus status,
    String? reviewObservation,
    required String reviewedById,
    String? reasonId, // Administrator can normalize with pre-registered reasonId
    PauseResponsibility? responsibility,
  });
  FutureBool cancelPause({
    required String id,
    required DateTime resumedAt,
    required String resumedById,
  });
}
