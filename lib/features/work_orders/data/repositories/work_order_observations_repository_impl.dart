import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: WorkOrderObservationsRepository)
final class WorkOrderObservationsRepositoryImpl
    implements WorkOrderObservationsRepository {
  const WorkOrderObservationsRepositoryImpl({
    required InternetClient internet,
    required WorkOrderObservationsRemoteDataSource remoteDataSource,
    required WorkOrderObservationsLocalDataSource localDataSource,
    required SessionRepository sessionRepository,
    required SyncRepository syncRepository,
    required OfflineTracker offlineTracker,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _sessionRepository = sessionRepository,
       _syncRepository = syncRepository,
       _offlineTracker = offlineTracker;

  final InternetClient _internet;
  final WorkOrderObservationsRemoteDataSource _remoteDataSource;
  final WorkOrderObservationsLocalDataSource _localDataSource;
  final SessionRepository _sessionRepository;
  final SyncRepository _syncRepository;
  final OfflineTracker _offlineTracker;

  bool get _isProviderMode =>
      AppMode.fromName(_sessionRepository.getSelectedMode()) ==
      AppMode.provider;

  @override
  FutureList<WorkOrderObservationEntity> getObservations(String workOrderId) {
    final isProvider = _isProviderMode;
    return RepositoryHandler.fetchWithFallbackAndMapList<
      WorkOrderObservationModel,
      WorkOrderObservationEntity
    >(
      isInternetConnected: _internet.isConnected,
      localCallback:
          isProvider
              ? null
              : () => _localDataSource.getObservations(workOrderId),
      remoteCallback: () => _remoteDataSource.getObservations(workOrderId),
      onRemoteSuccess:
          isProvider
              ? null
              : (list) async {
                await _localDataSource.saveObservations(list);
                return const SuccessState(data: true);
              },
    );
  }

  @override
  FutureData<WorkOrderObservationEntity> createObservation(
    WorkOrderObservationEntity observation,
  ) {
    final isProvider = _isProviderMode;
    final model = WorkOrderObservationModel.fromEntity(observation);
    return RepositoryHandler.fetchWithFallbackAndMap<
      WorkOrderObservationModel,
      WorkOrderObservationEntity
    >(
      isInternetConnected: _internet.isConnected,
      remoteCallback: () => _remoteDataSource.createObservation(model),
      onRemoteSuccess:
          isProvider
              ? null
              : (data) async {
                await _localDataSource.saveObservation(data);
                return const SuccessState(data: true);
              },
      localCallback:
          isProvider
              ? null
              : () async {
                final result = await _localDataSource.saveObservation(model);
                if (result is SuccessState) {
                  _offlineTracker.recordOfflineAction();
                  await _syncRepository.enqueue(
                    SyncQueueItemEntity(
                      id: const Uuid().v4(),
                      companyId: observation.companyId,
                      userProfileId:
                          observation.authorId ??
                          _sessionRepository.userData.user.id,
                      entityType: SyncEntityType.observation,
                      entityId: observation.id,
                      operation: SyncOperationType.create,
                      payload: jsonEncode(model.toJson()),
                      createdAt: DateTime.now(),
                    ),
                  );
                  return SuccessState(data: model);
                }
                return FailureState(message: (result as FailureState).message);
              },
    );
  }

  @override
  FutureBool deleteObservation(String observationId) {
    final isProvider = _isProviderMode;
    return RepositoryHandler.fetchWithFallback(
      isInternetConnected: _internet.isConnected,
      remoteCallback: () => _remoteDataSource.deleteObservation(observationId),
      onRemoteSuccess:
          isProvider
              ? null
              : (data) async {
                await _localDataSource.deleteObservation(observationId);
                return const SuccessState(data: true);
              },
      localCallback:
          isProvider
              ? null
              : () async {
                final result = await _localDataSource.deleteObservation(
                  observationId,
                );
                if (result is SuccessState && result.data == true) {
                  _offlineTracker.recordOfflineAction();
                  final companyId =
                      _sessionRepository.getSelectedCompanyId() ?? '';
                  final userId = _sessionRepository.userData.user.id;
                  await _syncRepository.enqueue(
                    SyncQueueItemEntity(
                      id: const Uuid().v4(),
                      companyId: companyId,
                      userProfileId: userId,
                      entityType: SyncEntityType.observation,
                      entityId: observationId,
                      operation: SyncOperationType.delete,
                      createdAt: DateTime.now(),
                    ),
                  );
                }
                return result;
              },
    );
  }
}
