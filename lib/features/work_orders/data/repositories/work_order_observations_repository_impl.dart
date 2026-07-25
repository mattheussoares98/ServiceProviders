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
  ) async {
    final model = WorkOrderObservationModel.fromEntity(observation);
    if (_internet.isConnected) {
      final remoteResult = await _remoteDataSource.createObservation(model);
      if (remoteResult is SuccessState<WorkOrderObservationModel>) {
        if (remoteResult.data != null) {
          await _localDataSource.saveObservation(remoteResult.data!);
          return SuccessState(data: remoteResult.data!.toEntity());
        }
      }
    }
    // Fallback to local save when offline or remote failed
    await _localDataSource.saveObservation(model);
    return SuccessState(data: model.toEntity());
  }

  @override
  FutureBool deleteObservation(String observationId) async {
    if (_internet.isConnected) {
      final remoteResult = await _remoteDataSource.deleteObservation(
        observationId,
      );
      if (remoteResult is SuccessState<bool>) {
        await _localDataSource.deleteObservation(observationId);
        return const SuccessState(data: true);
      }
    }
    await _localDataSource.deleteObservation(observationId);
    return const SuccessState(data: true);
  }
}
