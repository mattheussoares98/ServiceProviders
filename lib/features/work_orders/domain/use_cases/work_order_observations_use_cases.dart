import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';

@LazySingleton()
class GetWorkOrderObservationsUseCase
    implements UseCase<List<WorkOrderObservationEntity>, String> {
  const GetWorkOrderObservationsUseCase(this._repository);

  final WorkOrderObservationsRepository _repository;

  @override
  FutureList<WorkOrderObservationEntity> call(String workOrderId) =>
      _repository.getObservations(workOrderId);
}

@LazySingleton()
class CreateWorkOrderObservationUseCase
    implements UseCase<WorkOrderObservationEntity, WorkOrderObservationEntity> {
  const CreateWorkOrderObservationUseCase(this._repository);

  final WorkOrderObservationsRepository _repository;

  @override
  FutureData<WorkOrderObservationEntity> call(
    WorkOrderObservationEntity observation,
  ) => _repository.createObservation(observation);
}

@LazySingleton()
class DeleteWorkOrderObservationUseCase implements UseCase<bool, String> {
  const DeleteWorkOrderObservationUseCase(this._repository);

  final WorkOrderObservationsRepository _repository;

  @override
  FutureBool call(String observationId) =>
      _repository.deleteObservation(observationId);
}
