import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';

@LazySingleton()
class WatchWorkOrderObservationsRealtimeUseCase {
  const WatchWorkOrderObservationsRealtimeUseCase({
    required WorkOrderObservationsRepository repository,
  }) : _repository = repository;

  final WorkOrderObservationsRepository _repository;

  Stream<RealtimeEvent<WorkOrderObservationEntity>> call({
    String? companyId,
    String? workOrderId,
  }) => _repository.watchObservationsRealtime(
    companyId: companyId,
    workOrderId: workOrderId,
  );
}
