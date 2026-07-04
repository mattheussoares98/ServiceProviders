import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_type.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit_use_cases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

part 'work_orders_state.dart';

@injectable
class WorkOrdersCubit extends BaseCubit<WorkOrdersState> {
  WorkOrdersCubit({required WorkOrdersCubitUseCases useCases})
    : _useCases = useCases,
      super(const WorkOrdersState.initial());

  final WorkOrdersCubitUseCases _useCases;

  Future<void> loadWorkOrdersAndChangeRequests({
    bool showLoading = true,
  }) async {
    final user = _useCases.getSessionUser();
    if (user.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          workOrders: [],
          changeRequests: [],
        ),
      );
      return;
    }

    if (showLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final results = await Future.wait([
      _useCases.getWorkOrders(user.companyId),
      _useCases.getChangeRequests(user.companyId),
    ]);

    if (isClosed) return;

    final workOrdersResult = results[0];
    final changeRequestsResult = results[1];

    if (workOrdersResult is SuccessState<List<WorkOrderEntity>> &&
        changeRequestsResult
            is SuccessState<List<WorkOrderChangeRequestEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          workOrders: workOrdersResult.data,
          changeRequests: changeRequestsResult.data,
          annulErrorMessage: true,
        ),
      );
    } else {
      final errorMessage = workOrdersResult is FailureState
          ? workOrdersResult.message
          : changeRequestsResult.message;
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  Future<void> loadWorkOrderHistory(String workOrderId) async {
    final dataState = await _useCases.getWorkOrderHistory(workOrderId);
    if (isClosed) return;

    if (dataState is SuccessState<List<WorkOrderHistoryEntity>>) {
      final historyList = dataState.data ?? [];
      final updatedHistory = Map<String, List<WorkOrderHistoryEntity>>.from(
        state.historyByWorkOrder,
      );
      updatedHistory[workOrderId] = historyList;
      emit(state.copyWith(historyByWorkOrder: updatedHistory));
    } else {
      showDataStateToast(dataState);
    }
  }

  Future<bool> saveWorkOrder({
    required String? id,
    String? assetId,
    required String locationId,
    String? assignedToId,
    required String createdById,
    String? maintenancePlanId,
    required String title,
    String? description,
    required Priority priority,
    required WorkOrderStatus status,
    required WorkOrderType type,
    DateTime? scheduledDate,
    DateTime? startedAt,
    DateTime? completedAt,
    int? estimatedDuration,
    int? actualDuration,
    double? laborCost,
    double? partsCost,
    double? totalCost,
    String? notes,
    DateTime? createdAt,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));

    final isUpdate = id != null;
    final now = DateTime.now();
    final companyId = _useCases.getSessionUser().companyId;

    if (companyId.isEmpty) {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: state.errorMessage,
        ),
      );
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      return false;
    }

    final computedStartedAt = startedAt ??
        (status == WorkOrderStatus.inProgress ? now : null);

    DateTime? computedCompletedAt = completedAt;
    if (status == WorkOrderStatus.completed) {
      computedCompletedAt ??= now;
    } else if (status == WorkOrderStatus.open ||
        status == WorkOrderStatus.inProgress ||
        status == WorkOrderStatus.onHold) {
      computedCompletedAt = null;
    }

    final workOrder = WorkOrderEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      assetId: assetId?.trimToNull(),
      locationId: locationId,
      assignedToId: assignedToId?.trimToNull(),
      createdById: createdById,
      maintenancePlanId: maintenancePlanId?.trimToNull(),
      title: title.trim(),
      description: description?.trimToNull(),
      priority: priority,
      status: status,
      type: type,
      scheduledDate: scheduledDate,
      startedAt: computedStartedAt,
      completedAt: computedCompletedAt,
      estimatedDuration: estimatedDuration,
      actualDuration: actualDuration,
      laborCost: laborCost,
      partsCost: partsCost,
      totalCost: totalCost,
      notes: notes?.trimToNull(),
      createdAt: createdAt ?? now,
      updatedAt: now,
    );

    final dataState = isUpdate
        ? await _useCases.updateWorkOrder(workOrder)
        : await _useCases.createWorkOrder(workOrder);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      await loadWorkOrdersAndChangeRequests(showLoading: false);
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<bool> deleteWorkOrder(String id) async {
    emit(state.copyWith(status: StateStatus.deleting));
    final dataState = await _useCases.deleteWorkOrder(id);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      await loadWorkOrdersAndChangeRequests(showLoading: false);
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.deletingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<void> createChangeRequest(WorkOrderChangeRequestEntity request) async {
    emit(state.copyWith(status: StateStatus.saving));
    final dataState = await _useCases.createChangeRequest(request);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast(
        'Solicitação de alteração enviada com sucesso'.hardcoded,
      );
      await loadWorkOrdersAndChangeRequests(showLoading: false);
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
    }
  }

  Future<void> reviewChangeRequest(ReviewChangeRequestParams params) async {
    emit(state.copyWith(status: StateStatus.saving));
    final dataState = await _useCases.reviewChangeRequest(params);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast(
        'Solicitação de alteração avaliada com sucesso'.hardcoded,
      );
      await loadWorkOrdersAndChangeRequests(showLoading: false);
    } else {
      emit(
        state.copyWith(
          status: StateStatus.savingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(dataState);
    }
  }
}
