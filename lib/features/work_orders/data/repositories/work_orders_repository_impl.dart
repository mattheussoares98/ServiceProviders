import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_realtime_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/task_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: WorkOrdersRepository)
final class WorkOrdersRepositoryImpl implements WorkOrdersRepository {
  WorkOrdersRepositoryImpl({
    required InternetClient internet,
    required WorkOrdersRemoteDataSource remoteDataSource,
    required WorkOrdersRealtimeRemoteDataSource realtimeRemoteDataSource,
    required WorkOrdersLocalDataSource localDataSource,
    required SessionRepository sessionRepository,
    required SyncRepository syncRepository,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _realtimeRemoteDataSource = realtimeRemoteDataSource,
       _localDataSource = localDataSource,
       _sessionRepository = sessionRepository,
       _syncRepository = syncRepository;

  final InternetClient _internet;
  final WorkOrdersRemoteDataSource _remoteDataSource;
  final WorkOrdersRealtimeRemoteDataSource _realtimeRemoteDataSource;
  final WorkOrdersLocalDataSource _localDataSource;
  final SessionRepository _sessionRepository;
  final SyncRepository _syncRepository;

  bool get _isProviderMode =>
      AppMode.fromName(_sessionRepository.getSelectedMode()) ==
      AppMode.provider;

  @override
  FutureList<WorkOrderEntity> getWorkOrders(
    String companyId, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 50,
    int offset = 0,
  }) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        WorkOrderModel,
        WorkOrderEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getWorkOrders(
          companyId,
          filter: filter,
          pageSize: pageSize,
          offset: offset,
        ),
        remoteCallback: () => _remoteDataSource.getWorkOrders(
          companyId,
          filter: filter,
          pageSize: pageSize,
          offset: offset,
        ),
        onRemoteSuccess: (list) async {
          await _localDataSource.saveWorkOrders(list);
          return const SuccessState(data: true);
        },
      );

  @override
  FutureList<WorkOrderEntity> getProviderWorkOrders(
    List<String> serviceProviderCompanyIds, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 50,
    int offset = 0,
  }) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        WorkOrderModel,
        WorkOrderEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getProviderWorkOrders(
          serviceProviderCompanyIds,
          filter: filter,
          pageSize: pageSize,
          offset: offset,
        ),
        // Deliberately no localCallback and no onRemoteSuccess: provider mode is
        // online-only (V2 §1.4). The Drift database is scoped to one contracting
        // company, so caching cross-company orders there would corrupt the
        // internal-mode dataset. Offline yields FailureState.noInternet().
      );

  @override
  FutureData<WorkOrderEntity> getWorkOrderById(String id) {
    final isProvider = _isProviderMode;
    return RepositoryHandler.fetchWithFallbackAndMap<
      WorkOrderModel,
      WorkOrderEntity
    >(
      isInternetConnected: _internet.isConnected,
      localCallback: isProvider
          ? null
          : () => _localDataSource.getWorkOrderById(id),
      remoteCallback: () => _remoteDataSource.getWorkOrderById(id),
      onRemoteSuccess: isProvider ? null : _localDataSource.saveWorkOrder,
    );
  }

  @override
  FutureBool createWorkOrder(WorkOrderEntity workOrder) {
    final isProvider = _isProviderMode;
    return RepositoryHandler.fetchWithFallback<bool>(
      isInternetConnected: _internet.isConnected,
      localCallback: isProvider
          ? null
          : () async {
              final model = WorkOrderModel.fromEntity(workOrder);
              final result = await _localDataSource.saveWorkOrder(model);
              if (result is SuccessState<bool> && result.data == true) {
                await _syncRepository.enqueue(
                  SyncQueueItemEntity(
                    id: const Uuid().v4(),
                    companyId: workOrder.companyId,
                    userProfileId:
                        _sessionRepository.userData.user.id.isNotEmpty
                        ? _sessionRepository.userData.user.id
                        : (workOrder.createdById ?? ''),
                    entityType: SyncEntityType.workOrder,
                    entityId: workOrder.id,
                    operation: SyncOperationType.create,
                    payload: jsonEncode(model.toJson()),
                    createdAt: DateTime.now(),
                  ),
                );
              }
              return result;
            },
      remoteCallback: () async {
        final result = await _remoteDataSource.createWorkOrder(
          WorkOrderModel.fromEntity(workOrder),
        );
        if (result is SuccessState<bool> && result.data == true) {
          if (!isProvider) {
            await _localDataSource.saveWorkOrder(
              WorkOrderModel.fromEntity(workOrder),
            );
          }
          return const SuccessState(data: true);
        }
        return FailureState(
          message: result.message,
          error: result.error,
          statusCode: result.statusCode,
          response: result.response,
        );
      },
    );
  }

  @override
  FutureBool updateWorkOrder(WorkOrderEntity workOrder) {
    final isProvider = _isProviderMode;
    return RepositoryHandler.fetchWithFallback<bool>(
      isInternetConnected: _internet.isConnected,
      localCallback: isProvider
          ? null
          : () async {
              final model = WorkOrderModel.fromEntity(workOrder);
              final result = await _localDataSource.saveWorkOrder(model);
              if (result is SuccessState<bool> && result.data == true) {
                await _syncRepository.enqueue(
                  SyncQueueItemEntity(
                    id: const Uuid().v4(),
                    companyId: workOrder.companyId,
                    userProfileId:
                        _sessionRepository.userData.user.id.isNotEmpty
                        ? _sessionRepository.userData.user.id
                        : (workOrder.createdById ?? ''),
                    entityType: SyncEntityType.workOrder,
                    entityId: workOrder.id,
                    operation: SyncOperationType.update,
                    payload: jsonEncode(model.toJson()),
                    createdAt: DateTime.now(),
                  ),
                );
              }
              return result;
            },
      remoteCallback: () async {
        final result = await _remoteDataSource.updateWorkOrder(
          WorkOrderModel.fromEntity(workOrder),
        );
        if (result is SuccessState<bool> && result.data == true) {
          if (!isProvider) {
            await _localDataSource.saveWorkOrder(
              WorkOrderModel.fromEntity(workOrder),
            );
          }
          return const SuccessState(data: true);
        }
        return FailureState(
          message: result.message,
          error: result.error,
          statusCode: result.statusCode,
          response: result.response,
        );
      },
    );
  }

  @override
  FutureBool deleteWorkOrder(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () async {
          final result = await _localDataSource.deleteWorkOrder(id);
          if (result is SuccessState<bool> && result.data == true) {
            final companyId = _sessionRepository.getSelectedCompanyId() ?? '';
            final userId = _sessionRepository.userData.user.id;
            await _syncRepository.enqueue(
              SyncQueueItemEntity(
                id: const Uuid().v4(),
                companyId: companyId,
                userProfileId: userId,
                entityType: SyncEntityType.workOrder,
                entityId: id,
                operation: SyncOperationType.delete,
                createdAt: DateTime.now(),
              ),
            );
          }
          return result;
        },
        remoteCallback: () async {
          final result = await _remoteDataSource.deleteWorkOrder(id);
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.hardDeleteWorkOrder(id);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool hardDeleteWorkOrder(String id) =>
      _localDataSource.hardDeleteWorkOrder(id);

  @override
  FutureBool syncWorkOrders(String companyId) async {
    if (!_internet.isConnected) {
      return FailureState.noInternet();
    }
    final lastSyncAt = await _localDataSource.getLastUpdatedTimestamp(
      companyId,
    );

    if (lastSyncAt == null) {
      final result = await _remoteDataSource.getWorkOrders(
        companyId,
        pageSize: 100,
      );
      if (result is SuccessState<List<WorkOrderModel>>) {
        final list = result.data ?? [];
        await _localDataSource.saveWorkOrders(list);
        return const SuccessState(data: true);
      }
      return FailureState(
        message: result.message,
        error: result.error,
        statusCode: result.statusCode,
        response: result.response,
      );
    } else {
      final result = await _remoteDataSource.getWorkOrdersDelta(
        companyId,
        since: lastSyncAt,
      );
      if (result is SuccessState<List<WorkOrderModel>>) {
        final list = result.data ?? [];
        await _localDataSource.saveWorkOrders(list);
        return const SuccessState(data: true);
      }
      return FailureState(
        message: result.message,
        error: result.error,
        statusCode: result.statusCode,
        response: result.response,
      );
    }
  }

  @override
  FutureList<TaskEntity> getTasksByWorkOrder(String workOrderId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<TaskModel, TaskEntity>(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getTasksByWorkOrder(workOrderId),
        remoteCallback: () =>
            _remoteDataSource.getTasksByWorkOrder(workOrderId),
        onRemoteSuccess: (list) async {
          await Future.wait(list.map(_localDataSource.saveTask).toList());
          return const SuccessState(data: true);
        },
      );

  @override
  FutureBool createTask(TaskEntity task) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () async {
          final result = await _localDataSource.saveTask(
            TaskModel.fromEntity(task),
          );
          if (result is SuccessState<bool> && result.data == true) {
            final companyId = _sessionRepository.getSelectedCompanyId() ?? '';
            final userId = _sessionRepository.userData.user.id;
            await _syncRepository.enqueue(
              SyncQueueItemEntity(
                id: const Uuid().v4(),
                companyId: companyId,
                userProfileId: userId,
                entityType: SyncEntityType.task,
                entityId: task.id,
                operation: SyncOperationType.create,
                payload: jsonEncode(TaskRequestModel.fromEntity(task).toJson()),
                createdAt: DateTime.now(),
              ),
            );
          }
          return result;
        },
        remoteCallback: () async {
          final result = await _remoteDataSource.createTask(
            TaskRequestModel.fromEntity(task),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveTask(TaskModel.fromEntity(task));
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool updateTask(TaskEntity task) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () async {
          final result = await _localDataSource.saveTask(
            TaskModel.fromEntity(task),
          );
          if (result is SuccessState<bool> && result.data == true) {
            final companyId = _sessionRepository.getSelectedCompanyId() ?? '';
            final userId = _sessionRepository.userData.user.id;
            await _syncRepository.enqueue(
              SyncQueueItemEntity(
                id: const Uuid().v4(),
                companyId: companyId,
                userProfileId: userId,
                entityType: SyncEntityType.task,
                entityId: task.id,
                operation: SyncOperationType.update,
                payload: jsonEncode(TaskRequestModel.fromEntity(task).toJson()),
                createdAt: DateTime.now(),
              ),
            );
          }
          return result;
        },
        remoteCallback: () async {
          final result = await _remoteDataSource.updateTask(
            TaskRequestModel.fromEntity(task),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveTask(TaskModel.fromEntity(task));
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool deleteTask(String id) => RepositoryHandler.fetchWithFallback<bool>(
    isInternetConnected: _internet.isConnected,
    localCallback: () async {
      final result = await _localDataSource.deleteTask(id);
      if (result is SuccessState<bool> && result.data == true) {
        final companyId = _sessionRepository.getSelectedCompanyId() ?? '';
        final userId = _sessionRepository.userData.user.id;
        await _syncRepository.enqueue(
          SyncQueueItemEntity(
            id: const Uuid().v4(),
            companyId: companyId,
            userProfileId: userId,
            entityType: SyncEntityType.task,
            entityId: id,
            operation: SyncOperationType.delete,
            createdAt: DateTime.now(),
          ),
        );
      }
      return result;
    },
    remoteCallback: () async {
      final result = await _remoteDataSource.deleteTask(id);
      if (result is SuccessState<bool> && result.data == true) {
        await _localDataSource.deleteTask(id);
        return const SuccessState(data: true);
      }
      return FailureState(
        message: result.message,
        error: result.error,
        statusCode: result.statusCode,
        response: result.response,
      );
    },
  );

  @override
  FutureList<WorkOrderChangeRequestEntity> getChangeRequests(
    String companyId,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        WorkOrderChangeRequestModel,
        WorkOrderChangeRequestEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getChangeRequests(companyId),
        remoteCallback: () => _remoteDataSource.getChangeRequests(companyId),
        onRemoteSuccess: (list) async {
          await Future.wait(list.map(_localDataSource.saveChangeRequest));
          return const SuccessState(data: true);
        },
      );

  @override
  FutureBool createChangeRequest(WorkOrderChangeRequestEntity request) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () async {
          final result = await _localDataSource.saveChangeRequest(
            WorkOrderChangeRequestModel.fromEntity(request),
          );
          return result;
        },
        remoteCallback: () async {
          final result = await _remoteDataSource.createChangeRequest(
            WorkOrderChangeRequestRequestModel.fromEntity(request),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveChangeRequest(
              WorkOrderChangeRequestModel.fromEntity(request),
            );
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool reviewChangeRequest({
    required String id,
    required ChangeRequestStatus status,
    String? rejectionReason,
    required String reviewedById,
  }) => RepositoryHandler.fetchWithFallback<bool>(
    isInternetConnected: _internet.isConnected,
    localCallback: () async {
      final result = await _localDataSource.reviewChangeRequest(
        id: id,
        status: status.code,
        rejectionReason: rejectionReason,
        reviewedById: reviewedById,
      );
      return result;
    },
    remoteCallback: () async {
      final result = await _remoteDataSource.reviewChangeRequest(
        id: id,
        status: status.code,
        rejectionReason: rejectionReason,
        reviewedById: reviewedById,
      );
      if (result is SuccessState<bool> && result.data == true) {
        await _localDataSource.reviewChangeRequest(
          id: id,
          status: status.code,
          rejectionReason: rejectionReason,
          reviewedById: reviewedById,
        );
        return const SuccessState(data: true);
      }
      return FailureState(
        message: result.message,
        error: result.error,
        statusCode: result.statusCode,
        response: result.response,
      );
    },
  );

  @override
  FutureList<WorkOrderHistoryEntity> getWorkOrderHistory(String workOrderId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        WorkOrderHistoryModel,
        WorkOrderHistoryEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getWorkOrderHistory(workOrderId),
        remoteCallback: () =>
            _remoteDataSource.getWorkOrderHistory(workOrderId),
        onRemoteSuccess: (list) async {
          await Future.wait(list.map(_localDataSource.saveWorkOrderHistory));
          return const SuccessState(data: true);
        },
      );

  @override
  Stream<RealtimeEvent<WorkOrderEntity>> watchRealtimeWorkOrders({
    String? companyId,
  }) {
    final stream = _realtimeRemoteDataSource.watchWorkOrders(
      companyId: companyId,
    );
    return stream.asyncMap((event) async {
      if (!_isProviderMode) {
        if (event.eventType == RealtimeEventType.delete ||
            (event.entity != null && event.entity!.deletedAt != null)) {
          await _localDataSource.deleteWorkOrder(event.id);
        } else if (event.entity != null) {
          await _localDataSource.saveWorkOrders([event.entity!]);
        }
      }
      return RealtimeEvent<WorkOrderEntity>(
        eventType: event.eventType,
        id: event.id,
        companyId: event.companyId,
        entity: event.entity,
      );
    });
  }
}
