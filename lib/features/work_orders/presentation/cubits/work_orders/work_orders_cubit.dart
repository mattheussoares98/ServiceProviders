import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit_use_cases.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'work_orders_state.dart';

@injectable
class WorkOrdersCubit extends BaseCubit<WorkOrdersState> {
  WorkOrdersCubit({required WorkOrdersCubitUseCases useCases})
    : _useCases = useCases,
      super(const WorkOrdersState.initial());

  final WorkOrdersCubitUseCases _useCases;

  Future<void> loadWorkOrdersAndChangeRequests() async {
    final user = _useCases.getSessionUser();
    if (user.companyId.isEmpty) {
      showErrorToast(
        'Erro não esperado. O usuário está sem o ID da companhia'.hardcoded,
      );
      emit(
        state.copyWith(
          status: StateStatus.error,
          workOrders: [],
          changeRequests: [],
        ),
      );
      return;
    }

    emit(state.copyWith(status: StateStatus.loading));

    final results = await Future.wait([
      _useCases.getWorkOrders(user.companyId),
      _useCases.getChangeRequests(user.companyId),
    ]);

    if (isClosed) return;

    final workOrdersResult = results[0];
    final changeRequestsResult = results[1];

    if (workOrdersResult is SuccessState<List<WorkOrderEntity>> &&
        changeRequestsResult is SuccessState<List<WorkOrderChangeRequestEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          workOrders: workOrdersResult.data,
          changeRequests: changeRequestsResult.data,
        ),
      );
    } else {
      final errorMessage = workOrdersResult is FailureState
          ? workOrdersResult.message
          : changeRequestsResult.message;
      emit(
        state.copyWith(status: StateStatus.error, errorMessage: errorMessage),
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

  Future<void> createWorkOrder(WorkOrderEntity workOrder) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.createWorkOrder(workOrder);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Ordem de serviço criada com sucesso'.hardcoded);
      await loadWorkOrdersAndChangeRequests();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<void> updateWorkOrder(WorkOrderEntity workOrder) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.updateWorkOrder(workOrder);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Ordem de serviço atualizada com sucesso'.hardcoded);
      await loadWorkOrdersAndChangeRequests();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<void> deleteWorkOrder(String id) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.deleteWorkOrder(id);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Ordem de serviço excluída com sucesso'.hardcoded);
      await loadWorkOrdersAndChangeRequests();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<void> createChangeRequest(WorkOrderChangeRequestEntity request) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.createChangeRequest(request);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Solicitação de alteração enviada com sucesso'.hardcoded);
      await loadWorkOrdersAndChangeRequests();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }

  Future<void> reviewChangeRequest(ReviewChangeRequestParams params) async {
    emit(state.copyWith(status: StateStatus.loading));
    final dataState = await _useCases.reviewChangeRequest(params);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      showSuccessToast('Solicitação de alteração avaliada com sucesso'.hardcoded);
      await loadWorkOrdersAndChangeRequests();
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showDataStateToast(dataState);
    }
  }
}