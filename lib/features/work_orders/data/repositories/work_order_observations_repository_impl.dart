import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';

@LazySingleton(as: WorkOrderObservationsRepository)
final class WorkOrderObservationsRepositoryImpl
    implements WorkOrderObservationsRepository {
  const WorkOrderObservationsRepositoryImpl({
    required WorkOrderObservationsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final WorkOrderObservationsRemoteDataSource _remoteDataSource;

  @override
  FutureList<WorkOrderObservationEntity> getObservations(String workOrderId) =>
      _remoteDataSource.getObservations(workOrderId);

  @override
  FutureData<WorkOrderObservationEntity> createObservation(
    WorkOrderObservationEntity observation,
  ) => _remoteDataSource.createObservation(
    WorkOrderObservationModel.fromEntity(observation),
  );

  @override
  FutureBool deleteObservation(String observationId) =>
      _remoteDataSource.deleteObservation(observationId);
}
