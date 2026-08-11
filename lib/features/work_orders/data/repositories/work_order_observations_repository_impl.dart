import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';

@LazySingleton(as: WorkOrderObservationsRepository)
final class WorkOrderObservationsRepositoryImpl
    implements WorkOrderObservationsRepository {
  const WorkOrderObservationsRepositoryImpl({
    required InternetClient internet,
    required WorkOrderObservationsRemoteDataSource remoteDataSource,
    required WorkOrderObservationsLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final WorkOrderObservationsRemoteDataSource _remoteDataSource;
  final WorkOrderObservationsLocalDataSource _localDataSource;

  @override
  FutureList<WorkOrderObservationEntity> getObservations(String workOrderId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        WorkOrderObservationModel,
        WorkOrderObservationEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getObservations(workOrderId),
        remoteCallback: () => _remoteDataSource.getObservations(workOrderId),
        onRemoteSuccess: (list) async {
          await _localDataSource.saveObservations(list);
          return const SuccessState(data: true);
        },
      );

  @override
  FutureData<WorkOrderObservationEntity> createObservation(
    WorkOrderObservationEntity observation,
  ) {
    final model = WorkOrderObservationModel.fromEntity(observation);
    return RepositoryHandler.fetchWithFallbackAndMap<
      WorkOrderObservationModel,
      WorkOrderObservationEntity
    >(
      isInternetConnected: _internet.isConnected,
      remoteCallback: () => _remoteDataSource.createObservation(model),
      onRemoteSuccess: (data) async {
        await _localDataSource.saveObservation(data);
        return const SuccessState(data: true);
      },
      localCallback: () async {
        final result = await _localDataSource.saveObservation(model);
        if (result is SuccessState) {
          return SuccessState(data: model);
        }
        return FailureState(message: (result as FailureState).message);
      },
    );
  }

  @override
  FutureBool deleteObservation(String observationId) {
    return RepositoryHandler.fetchWithFallback(
      isInternetConnected: _internet.isConnected,
      remoteCallback: () => _remoteDataSource.deleteObservation(observationId),
      onRemoteSuccess: (data) async {
        await _localDataSource.deleteObservation(observationId);
        return const SuccessState(data: true);
      },
      localCallback: () => _localDataSource.deleteObservation(observationId),
    );
  }
}
