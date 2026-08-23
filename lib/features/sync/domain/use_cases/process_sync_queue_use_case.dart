import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_error_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:uuid/uuid.dart';

@LazySingleton()
class ProcessSyncQueueUseCase implements UseCaseNoParameter<int> {
  const ProcessSyncQueueUseCase({
    required SyncRepository syncRepository,
    required WorkOrdersRemoteDataSource workOrdersRemoteDataSource,
    required WorkOrderObservationsRemoteDataSource observationsRemoteDataSource,
    required PauseRemoteDataSource pauseRemoteDataSource,
    required InternetClient internet,
  }) : _syncRepository = syncRepository,
       _workOrdersRemoteDataSource = workOrdersRemoteDataSource,
       _observationsRemoteDataSource = observationsRemoteDataSource,
       _pauseRemoteDataSource = pauseRemoteDataSource,
       _internet = internet;

  final SyncRepository _syncRepository;
  final WorkOrdersRemoteDataSource _workOrdersRemoteDataSource;
  final WorkOrderObservationsRemoteDataSource _observationsRemoteDataSource;
  final PauseRemoteDataSource _pauseRemoteDataSource;
  final InternetClient _internet;

  @override
  FutureData<int> call() async {
    if (!_internet.isConnected) {
      return FailureState.noInternet();
    }

    final pendingResult = await _syncRepository.getPendingItems();
    if (pendingResult is! SuccessState<List<SyncQueueItemEntity>>) {
      return FailureState(
        message: (pendingResult as FailureState).message,
        error: pendingResult.error,
        statusCode: pendingResult.statusCode,
      );
    }

    final items = pendingResult.data ?? [];
    if (items.isEmpty) {
      return const SuccessState(data: 0);
    }

    int processedCount = 0;

    for (final item in items) {
      if (!_internet.isConnected) {
        break;
      }

      await _syncRepository.markItemSyncing(item.id);

      final dispatchResult = await _dispatchItem(item);

      if (dispatchResult is SuccessState<bool> && dispatchResult.data == true) {
        await _syncRepository.removeQueueItem(item.id);
        processedCount++;
      } else {
        final failure = dispatchResult as FailureState<bool>;

        if (!_internet.isConnected) {
          break;
        }

        final errorMsg = failure.message ?? failure.error.toString();
        await _syncRepository.markItemFailed(item.id, errorMsg);

        await _syncRepository.reportSyncError(
          SyncErrorEntity(
            id: const Uuid().v4(),
            companyId: item.companyId,
            userId: item.userProfileId,
            entityType: item.entityType,
            entityId: item.entityId,
            operation: item.operation,
            payload: item.payload,
            errorType:
                failure.statusCode != null
                    ? 'HTTP_${failure.statusCode}'
                    : 'SyncError',
            errorMessage: errorMsg,
            attempts: item.attempts + 1,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    return SuccessState(data: processedCount);
  }

  FutureData<bool> _dispatchItem(SyncQueueItemEntity item) async {
    try {
      final payloadMap =
          item.payload != null && item.payload!.isNotEmpty
              ? jsonDecode(item.payload!) as MapDynamic
              : <String, dynamic>{};

      return switch (item.entityType) {
        SyncEntityType.workOrder => _dispatchWorkOrder(item, payloadMap),
        SyncEntityType.task => _dispatchTask(item, payloadMap),
        SyncEntityType.observation => _dispatchObservation(item, payloadMap),
        SyncEntityType.pauseRequest => _dispatchPauseRequest(item, payloadMap),
        SyncEntityType.attachment => const SuccessState(data: true),
      };
    } catch (e) {
      return FailureState(message: e.toString(), error: e.toString());
    }
  }

  FutureData<bool> _dispatchWorkOrder(
    SyncQueueItemEntity item,
    MapDynamic payloadMap,
  ) => switch (item.operation) {
    SyncOperationType.create => _workOrdersRemoteDataSource.createWorkOrder(
      WorkOrderModel.fromJson(payloadMap),
    ),
    SyncOperationType.update => _workOrdersRemoteDataSource.updateWorkOrder(
      WorkOrderModel.fromJson(payloadMap),
    ),
    SyncOperationType.delete => _workOrdersRemoteDataSource.deleteWorkOrder(
      item.entityId,
    ),
  };

  FutureData<bool> _dispatchTask(
    SyncQueueItemEntity item,
    MapDynamic payloadMap,
  ) => switch (item.operation) {
    SyncOperationType.create => _workOrdersRemoteDataSource.createTask(
      TaskRequestModel.fromJson(payloadMap),
    ),
    SyncOperationType.update => _workOrdersRemoteDataSource.updateTask(
      TaskRequestModel.fromJson(payloadMap),
    ),
    SyncOperationType.delete => _workOrdersRemoteDataSource.deleteTask(
      item.entityId,
    ),
  };

  FutureData<bool> _dispatchObservation(
    SyncQueueItemEntity item,
    MapDynamic payloadMap,
  ) async {
    return switch (item.operation) {
      SyncOperationType.create => () async {
        final res = await _observationsRemoteDataSource.createObservation(
          WorkOrderObservationModel.fromJson(payloadMap),
        );
        return res is SuccessState
            ? const SuccessState(data: true)
            : FailureState<bool>(
              message: (res as FailureState).message,
              error: res.error,
              statusCode: res.statusCode,
            );
      }(),
      SyncOperationType.delete =>
        _observationsRemoteDataSource.deleteObservation(item.entityId),
      _ => const SuccessState(data: true),
    };
  }

  FutureData<bool> _dispatchPauseRequest(
    SyncQueueItemEntity item,
    MapDynamic payloadMap,
  ) => switch (item.operation) {
    SyncOperationType.create => _pauseRemoteDataSource.requestPause(
      PauseRequestModel.fromJson(payloadMap),
    ),
    _ => Future.value(const SuccessState(data: true)),
  };
}
