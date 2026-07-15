import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_response_model.dart';
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
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final WorkOrdersRemoteDataSource _remoteDataSource;
  final WorkOrdersLocalDataSource _localDataSource;

  @override
  FutureList<WorkOrderEntity> getWorkOrders(
    String companyId, {
    WorkOrderFilter filter = const WorkOrderFilter(),
    int pageSize = 20,
    int offset = 0,
  }) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        WorkOrderResponseModel,
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
          // Cache locally only when offset is 0 (first page) to keep the local database updated with
          // the latest/most relevant orders, while preventing local database storage bloat with endless
          // scrolled items.
          if (offset == 0) {
            await Future.wait(
              list.map(_localDataSource.saveWorkOrder).toList(),
            );
          }
          return const SuccessState(data: true);
        },
      );

  @override
  FutureData<WorkOrderEntity> getWorkOrderById(String id) =>
      RepositoryHandler.fetchWithFallbackAndMap<
        WorkOrderResponseModel,
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
        localCallback: () => _localDataSource.saveWorkOrder(
          WorkOrderResponseModel.fromEntity(workOrder),
        ),
        remoteCallback: () async {
          final result = await _remoteDataSource.createWorkOrder(
            WorkOrderResponseModel.fromEntity(workOrder),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveWorkOrder(
              WorkOrderResponseModel.fromEntity(workOrder),
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
        localCallback: () => _localDataSource.saveWorkOrder(
          WorkOrderResponseModel.fromEntity(workOrder),
        ),
        remoteCallback: () async {
          final result = await _remoteDataSource.updateWorkOrder(
            WorkOrderResponseModel.fromEntity(workOrder),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveWorkOrder(
              WorkOrderResponseModel.fromEntity(workOrder),
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
        localCallback: () => _localDataSource.deleteWorkOrder(id),
        remoteCallback: () async {
          final result = await _remoteDataSource.deleteWorkOrder(id);
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.deleteWorkOrder(id);
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
  FutureList<TaskEntity> getTasksByWorkOrder(String workOrderId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        TaskResponseModel,
        TaskEntity
      >(
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
        localCallback: () =>
            _localDataSource.saveTask(TaskResponseModel.fromEntity(task)),
        remoteCallback: () async {
          final result = await _remoteDataSource.createTask(
            TaskRequestModel.fromEntity(task),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveTask(TaskResponseModel.fromEntity(task));
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
        localCallback: () =>
            _localDataSource.saveTask(TaskResponseModel.fromEntity(task)),
        remoteCallback: () async {
          final result = await _remoteDataSource.updateTask(
            TaskRequestModel.fromEntity(task),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveTask(TaskResponseModel.fromEntity(task));
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
    localCallback: () => _localDataSource.deleteTask(id),
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
        WorkOrderChangeRequestResponseModel,
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
        localCallback: () => _localDataSource.saveChangeRequest(
          WorkOrderChangeRequestResponseModel.fromEntity(request),
        ),
        remoteCallback: () async {
          final result = await _remoteDataSource.createChangeRequest(
            WorkOrderChangeRequestRequestModel.fromEntity(request),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveChangeRequest(
              WorkOrderChangeRequestResponseModel.fromEntity(request),
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
    localCallback: () => _localDataSource.reviewChangeRequest(
      id: id,
      status: status.code,
      rejectionReason: rejectionReason,
      reviewedById: reviewedById,
    ),
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
        WorkOrderHistoryResponseModel,
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
