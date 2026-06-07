import 'package:clean_architecture/core/clients/remote/http/http_client.dart';
import 'package:clean_architecture/core/data/handlers/api_handler.dart';
import 'package:clean_architecture/core/constants/api_endpoints.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/requests/work_order_request_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/task_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_change_request_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_history_response_model.dart';
import 'package:clean_architecture/features/work_orders/data/models/responses/work_order_response_model.dart';
import 'package:injectable/injectable.dart';

abstract interface class WorkOrdersRemoteDataSource {
  // Work Orders
  FutureList<WorkOrderResponseModel> getWorkOrders(String companyId);
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id);
  FutureBool createWorkOrder(WorkOrderRequestModel request);
  FutureBool updateWorkOrder(WorkOrderRequestModel request);
  FutureBool deleteWorkOrder(String id);

  // Tasks
  FutureList<TaskResponseModel> getTasksByWorkOrder(String workOrderId);
  FutureBool createTask(TaskRequestModel request);
  FutureBool updateTask(TaskRequestModel request);
  FutureBool deleteTask(String id);

  // Change Requests
  FutureList<WorkOrderChangeRequestResponseModel> getChangeRequests(String companyId);
  FutureBool createChangeRequest(WorkOrderChangeRequestRequestModel request);
  FutureBool reviewChangeRequest({
    required String id,
    required String status,
    String? rejectionReason,
    required String reviewedById,
  });

  // History
  FutureList<WorkOrderHistoryResponseModel> getWorkOrderHistory(String workOrderId);
}

@LazySingleton(as: WorkOrdersRemoteDataSource)
final class WorkOrdersRemoteDataSourceImpl implements WorkOrdersRemoteDataSource {
  const WorkOrdersRemoteDataSourceImpl({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;

  // ============================================
  // Work Orders
  // ============================================

  @override
  FutureList<WorkOrderResponseModel> getWorkOrders(String companyId) =>
      ApiHandler.call(
        () => _httpClient.get(ApiEndpoints.workOrders, queryParameters: {'company_id': companyId}),
        fromJson: WorkOrderResponseModel.fromJson,
      );

  @override
  FutureData<WorkOrderResponseModel> getWorkOrderById(String id) =>
      ApiHandler.call(
        () => _httpClient.get(ApiEndpoints.workOrderById(id)),
        fromJson: WorkOrderResponseModel.fromJson,
      );

  @override
  FutureBool createWorkOrder(WorkOrderRequestModel request) =>
      ApiHandler.staticCall(
        () => _httpClient.post(ApiEndpoints.workOrders, data: request.toJson()),
        staticData: true,
      );

  @override
  FutureBool updateWorkOrder(WorkOrderRequestModel request) =>
      ApiHandler.staticCall(
        () => _httpClient.put(ApiEndpoints.workOrderById(request.id), data: request.toJson()),
        staticData: true,
      );

  @override
  FutureBool deleteWorkOrder(String id) =>
      ApiHandler.staticCall(
        () => _httpClient.delete(ApiEndpoints.workOrderById(id)),
        staticData: true,
      );

  // ============================================
  // Tasks
  // ============================================

  @override
  FutureList<TaskResponseModel> getTasksByWorkOrder(String workOrderId) =>
      ApiHandler.call(
        () => _httpClient.get(ApiEndpoints.tasks, queryParameters: {'work_order_id': workOrderId}),
        fromJson: TaskResponseModel.fromJson,
      );

  @override
  FutureBool createTask(TaskRequestModel request) =>
      ApiHandler.staticCall(
        () => _httpClient.post(ApiEndpoints.tasks, data: request.toJson()),
        staticData: true,
      );

  @override
  FutureBool updateTask(TaskRequestModel request) =>
      ApiHandler.staticCall(
        () => _httpClient.put(ApiEndpoints.taskById(request.id), data: request.toJson()),
        staticData: true,
      );

  @override
  FutureBool deleteTask(String id) =>
      ApiHandler.staticCall(
        () => _httpClient.delete(ApiEndpoints.taskById(id)),
        staticData: true,
      );

  // ============================================
  // Change Requests
  // ============================================

  @override
  FutureList<WorkOrderChangeRequestResponseModel> getChangeRequests(String companyId) =>
      ApiHandler.call(
        () => _httpClient.get(ApiEndpoints.changeRequests, queryParameters: {'company_id': companyId}),
        fromJson: WorkOrderChangeRequestResponseModel.fromJson,
      );

  @override
  FutureBool createChangeRequest(WorkOrderChangeRequestRequestModel request) =>
      ApiHandler.staticCall(
        () => _httpClient.post(ApiEndpoints.changeRequests, data: request.toJson()),
        staticData: true,
      );

  @override
  FutureBool reviewChangeRequest({
    required String id,
    required String status,
    String? rejectionReason,
    required String reviewedById,
  }) =>
      ApiHandler.staticCall(
        () => _httpClient.post(
          '${ApiEndpoints.changeRequests}/$id/review',
          data: {
            'status': status,
            'rejection_reason': rejectionReason,
            'reviewed_by_id': reviewedById,
          },
        ),
        staticData: true,
      );

  // ============================================
  // History
  // ============================================

  @override
  FutureList<WorkOrderHistoryResponseModel> getWorkOrderHistory(String workOrderId) =>
      ApiHandler.call(
        () => _httpClient.get(ApiEndpoints.workOrderHistory, queryParameters: {'work_order_id': workOrderId}),
        fromJson: WorkOrderHistoryResponseModel.fromJson,
      );
}
