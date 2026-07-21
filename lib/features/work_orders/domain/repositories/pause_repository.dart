import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';

abstract interface class PauseRepository {
  FutureList<PauseRequestEntity> getPauseRequests(String workOrderId);
  FutureBool requestPause(PauseRequestEntity pauseRequest);
  FutureBool reviewPause({
    required String id,
    required PauseRequestStatus status,
    String? reviewObservation,
    required String reviewedById,
  });
  FutureBool cancelPause({required String id, required DateTime resumedAt});
}
