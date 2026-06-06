import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:clean_architecture/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';
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

  // TODO: Wire to local/remote data sources with RepositoryHandler
  @override
  FutureList<WorkOrderEntity> getWorkOrders(String companyId) =>
      throw UnimplementedError();

  @override
  FutureData<WorkOrderEntity> getWorkOrderById(String id) =>
      throw UnimplementedError();

  @override
  FutureBool createWorkOrder(WorkOrderEntity workOrder) =>
      throw UnimplementedError();

  @override
  FutureBool updateWorkOrder(WorkOrderEntity workOrder) =>
      throw UnimplementedError();

  @override
  FutureBool deleteWorkOrder(String id) => throw UnimplementedError();

  @override
  FutureList<TaskEntity> getTasksByWorkOrder(String workOrderId) =>
      throw UnimplementedError();

  @override
  FutureBool createTask(TaskEntity task) => throw UnimplementedError();

  @override
  FutureBool updateTask(TaskEntity task) => throw UnimplementedError();

  @override
  FutureBool deleteTask(String id) => throw UnimplementedError();

  @override
  FutureList<WorkOrderChangeRequestEntity> getChangeRequests(
          String companyId) =>
      throw UnimplementedError();

  @override
  FutureBool createChangeRequest(WorkOrderChangeRequestEntity request) =>
      throw UnimplementedError();

  @override
  FutureBool reviewChangeRequest({
    required String id,
    required ChangeRequestStatus status,
    String? rejectionReason,
    required String reviewedById,
  }) =>
      throw UnimplementedError();

  @override
  FutureList<WorkOrderHistoryEntity> getWorkOrderHistory(
          String workOrderId) =>
      throw UnimplementedError();
}
