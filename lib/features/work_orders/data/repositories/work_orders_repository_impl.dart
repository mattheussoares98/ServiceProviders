import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/task_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: WorkOrdersRepository)
final class WorkOrdersRepositoryImpl implements WorkOrdersRepository {
  WorkOrdersRepositoryImpl({
    required InternetClient internet,
    required WorkOrdersRemoteDataSource remoteDataSource,
    required WorkOrdersLocalDataSource localDataSource,
  })  : _internet = internet,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final InternetClient _internet;
  final WorkOrdersRemoteDataSource _remoteDataSource;
  final WorkOrdersLocalDataSource _localDataSource;

  @override
  FutureList<WorkOrderEntity> getWorkOrders(String companyId) =>
      RepositoryHandler.fetchFromLocalAndMapList<WorkOrderResponseModel,
          WorkOrderEntity>(
        localCallback: () => _localDataSource.getWorkOrders(companyId),
      );

  @override
  FutureData<WorkOrderEntity> getWorkOrderById(String id) =>
      RepositoryHandler.fetchFromLocalAndMap<WorkOrderResponseModel,
          WorkOrderEntity>(
        localCallback: () => _localDataSource.getWorkOrderById(id),
      );

  @override
  FutureBool createWorkOrder(WorkOrderEntity workOrder) =>
      _localDataSource.saveWorkOrder(WorkOrderResponseModel.fromEntity(workOrder));

  @override
  FutureBool updateWorkOrder(WorkOrderEntity workOrder) =>
      _localDataSource.saveWorkOrder(WorkOrderResponseModel.fromEntity(workOrder));

  @override
  FutureBool deleteWorkOrder(String id) => _localDataSource.deleteWorkOrder(id);

  @override
  FutureList<TaskEntity> getTasksByWorkOrder(String workOrderId) =>
      RepositoryHandler.fetchFromLocalAndMapList<TaskResponseModel, TaskEntity>(
        localCallback: () => _localDataSource.getTasksByWorkOrder(workOrderId),
      );

  @override
  FutureBool createTask(TaskEntity task) =>
      _localDataSource.saveTask(TaskResponseModel.fromEntity(task));

  @override
  FutureBool updateTask(TaskEntity task) =>
      _localDataSource.saveTask(TaskResponseModel.fromEntity(task));

  @override
  FutureBool deleteTask(String id) => _localDataSource.deleteTask(id);

  @override
  FutureList<WorkOrderChangeRequestEntity> getChangeRequests(
          String companyId) =>
      RepositoryHandler.fetchFromLocalAndMapList<
          WorkOrderChangeRequestResponseModel, WorkOrderChangeRequestEntity>(
        localCallback: () => _localDataSource.getChangeRequests(companyId),
      );

  @override
  FutureBool createChangeRequest(WorkOrderChangeRequestEntity request) =>
      _localDataSource.saveChangeRequest(
          WorkOrderChangeRequestResponseModel.fromEntity(request));

  @override
  FutureBool reviewChangeRequest({
    required String id,
    required ChangeRequestStatus status,
    String? rejectionReason,
    required String reviewedById,
  }) =>
      _localDataSource.reviewChangeRequest(
        id: id,
        status: status.code,
        rejectionReason: rejectionReason,
        reviewedById: reviewedById,
      );

  @override
  FutureList<WorkOrderHistoryEntity> getWorkOrderHistory(
          String workOrderId) =>
      RepositoryHandler.fetchFromLocalAndMapList<
          WorkOrderHistoryResponseModel, WorkOrderHistoryEntity>(
        localCallback: () => _localDataSource.getWorkOrderHistory(workOrderId),
      );
}
