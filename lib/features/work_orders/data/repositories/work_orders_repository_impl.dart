import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
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

@LazySingleton(as: WorkOrdersRepository)
final class WorkOrdersRepositoryImpl implements WorkOrdersRepository {
  WorkOrdersRepositoryImpl({
    required InternetClient internet,
    required WorkOrdersRemoteDataSource remoteDataSource,
    required WorkOrdersLocalDataSource localDataSource,
    required OfflineTracker offlineTracker,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _offlineTracker = offlineTracker;

  final InternetClient _internet;
  final WorkOrdersRemoteDataSource _remoteDataSource;
  final WorkOrdersLocalDataSource _localDataSource;
  final OfflineTracker _offlineTracker;

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
  FutureData<WorkOrderEntity> getWorkOrderById(String id) =>
      RepositoryHandler.fetchWithFallbackAndMap<
        WorkOrderModel,
        WorkOrderEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getWorkOrderById(id),
        remoteCallback: () => _remoteDataSource.getWorkOrderById(id),
        onRemoteSuccess: _localDataSource.saveWorkOrder,
      );

  @override
  FutureBool createWorkOrder(WorkOrderEntity workOrder) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () async {
          final result = await _localDataSource.saveWorkOrder(
            WorkOrderModel.fromEntity(workOrder),
          );
          if (result is SuccessState<bool> && result.data == true) {
            _offlineTracker.recordOfflineAction();
          }
          return result;
        },
        remoteCallback: () async {
          final result = await _remoteDataSource.createWorkOrder(
            WorkOrderModel.fromEntity(workOrder),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveWorkOrder(
              WorkOrderModel.fromEntity(workOrder),
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
  FutureBool updateWorkOrder(WorkOrderEntity workOrder) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () async {
          final result = await _localDataSource.saveWorkOrder(
            WorkOrderModel.fromEntity(workOrder),
          );
          if (result is SuccessState<bool> && result.data == true) {
            _offlineTracker.recordOfflineAction();
          }
          return result;
        },
        remoteCallback: () async {
          final result = await _remoteDataSource.updateWorkOrder(
            WorkOrderModel.fromEntity(workOrder),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveWorkOrder(
              WorkOrderModel.fromEntity(workOrder),
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
  FutureBool deleteWorkOrder(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () async {
          final result = await _localDataSource.deleteWorkOrder(id);
          if (result is SuccessState<bool> && result.data == true) {
            _offlineTracker.recordOfflineAction();
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
        _offlineTracker.reset();
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
        _offlineTracker.reset();
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
            _offlineTracker.recordOfflineAction();
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
            _offlineTracker.recordOfflineAction();
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
        _offlineTracker.recordOfflineAction();
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
          if (result is SuccessState<bool> && result.data == true) {
            _offlineTracker.recordOfflineAction();
          }
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
      if (result is SuccessState<bool> && result.data == true) {
        _offlineTracker.recordOfflineAction();
      }
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
}
