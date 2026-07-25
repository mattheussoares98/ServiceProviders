import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';

abstract interface class WorkOrderObservationsRepository {
  FutureList<WorkOrderObservationEntity> getObservations(String workOrderId);
  FutureData<WorkOrderObservationEntity> createObservation(
      WorkOrderObservationEntity observation);
  FutureBool deleteObservation(String observationId);
}
