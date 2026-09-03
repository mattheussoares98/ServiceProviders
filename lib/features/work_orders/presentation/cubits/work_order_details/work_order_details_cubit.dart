import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_work_order_change_request_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_details/work_order_details_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'work_order_details_state.dart';

@injectable
class WorkOrderDetailsCubit extends BaseCubit<WorkOrderDetailsState> {
  WorkOrderDetailsCubit({required WorkOrderDetailsCubitUseCases useCases})
    : _useCases = useCases,
      super(const WorkOrderDetailsState.initial()) {
    _initRealtime();
  }

  final WorkOrderDetailsCubitUseCases _useCases;
  StreamSubscription<RealtimeEvent<WorkOrderEntity>>? _realtimeSubscription;

  bool get _isProviderMode =>
      AppMode.fromName(_useCases.getSelectedMode()) == AppMode.provider;

  void _initRealtime() {
    _realtimeSubscription?.cancel();
    final companyId = _isProviderMode ? null : _useCases.getActiveCompanyId();
    _realtimeSubscription = _useCases
        .watchWorkOrdersRealtime(companyId: companyId)
        .listen(_handleRealtimeEvent);
  }

  void _handleRealtimeEvent(RealtimeEvent<WorkOrderEntity> event) {
    if (isClosed) return;
    final current = state.workOrder;
    if (current == null || current.id != event.id) return;

    switch (event.eventType) {
      case RealtimeEventType.update:
        if (event.entity != null) {
          emit(state.copyWith(workOrder: event.entity));
        }
      case RealtimeEventType.delete:
        emit(state.copyWith(annulWorkOrder: true));
      case RealtimeEventType.insert:
        break;
    }
  }

  Future<bool> loadWorkOrder(String id, {bool showLoading = false}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

    final dataState = await _useCases.getWorkOrderById(id);
    if (isClosed) return false;

    if (dataState is SuccessState<WorkOrderEntity> && dataState.data != null) {
      emit(
        state.copyWith(
          workOrder: dataState.data,
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
      return true;
    } else {
      if (showLoading) {
        emit(
          state.copyWith(
            sections: withSection(
              BaseSections.load,
              SectionStatus.error,
              errorMessage: dataState.message,
            ),
          ),
        );
      } else {
        showDataStateToast(dataState);
      }
      return false;
    }
  }

  Future<bool> changeWorkOrderStatus({
    required WorkOrderEntity workOrder,
    required WorkOrderStatus status,
  }) async {
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderDetailsSections.changeStatus,
          SectionStatus.running,
        ),
      ),
    );

    final now = DateTime.now();

    final computedStartedAt =
        workOrder.startedAt ??
        (status == WorkOrderStatus.inProgress ? now : null);

    DateTime? computedCompletedAt = workOrder.completedAt;
    bool annulCompletedAt = false;

    if (status == WorkOrderStatus.completed) {
      computedCompletedAt ??= now;
    } else if (status == WorkOrderStatus.open ||
        status == WorkOrderStatus.inProgress ||
        status == WorkOrderStatus.onHold) {
      computedCompletedAt = null;
      annulCompletedAt = true;
    }

    final updatedWorkOrder = workOrder.copyWith(
      status: status,
      startedAt: computedStartedAt,
      completedAt: computedCompletedAt,
      annulCompletedAt: annulCompletedAt,
      updatedAt: now,
    );

    final dataState = await _useCases.updateWorkOrder(updatedWorkOrder);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(
        state.copyWith(
          workOrder: updatedWorkOrder,
          sections: withSection(
            WorkOrderDetailsSections.changeStatus,
            SectionStatus.success,
          ),
        ),
      );
      return true;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrderDetailsSections.changeStatus,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<bool> _resumePausedWorkOrder({
    required WorkOrderEntity workOrder,
    required String currentUserId,
    required String pauseId,
  }) async {
    final cancelResult = await _useCases.cancelPause(
      CancelPauseParams(
        id: pauseId,
        workOrderId: workOrder.id,
        resumedAt: DateTime.now(),
        resumedById: currentUserId,
      ),
    );
    if (isClosed) return false;

    if (cancelResult is FailureState) {
      showDataStateToast(cancelResult);
      return false;
    }

    final updatedWorkOrder = workOrder.copyWith(
      status: WorkOrderStatus.inProgress,
      updatedAt: DateTime.now(),
    );
    emit(state.copyWith(workOrder: updatedWorkOrder));

    return true;
  }

  Future<bool> resumeWork({
    required WorkOrderEntity workOrder,
    required String currentUserId,
    required PauseWorkflowCubit pauseCubit,
  }) async {
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderDetailsSections.resumeWork,
          SectionStatus.running,
        ),
      ),
    );

    var success = false;
    try {
      final pendingCompletion = pauseCubit.pendingCompletionRequest;
      final activePause = pauseCubit.activePauseRequest;

      if (workOrder.status.isPendingConclusionApproval &&
          pendingCompletion != null) {
        success = await pauseCubit.reviewCompletion(
          id: pendingCompletion.id,
          status: PauseRequestStatus.cancelled,
          reviewedById: currentUserId,
          workOrderId: workOrder.id,
        );
        if (success) {
          final updatedWorkOrder = workOrder.copyWith(
            status: WorkOrderStatus.inProgress,
            updatedAt: DateTime.now(),
          );
          emit(state.copyWith(workOrder: updatedWorkOrder));
        }
      } else if (activePause != null) {
        success = await _resumePausedWorkOrder(
          workOrder: workOrder,
          currentUserId: currentUserId,
          pauseId: activePause.id,
        );
      } else {
        success = await changeWorkOrderStatus(
          workOrder: workOrder,
          status: WorkOrderStatus.inProgress,
        );
      }

      if (success) {
        await pauseCubit.loadPauseRequests(workOrder.id);
      }
    } finally {
      if (!isClosed) {
        emit(
          state.copyWith(
            sections: withSection(
              WorkOrderDetailsSections.resumeWork,
              success ? SectionStatus.success : SectionStatus.error,
            ),
          ),
        );
      }
    }

    return success;
  }

  Future<bool> concludeDirectly({required WorkOrderEntity workOrder}) =>
      changeWorkOrderStatus(
        workOrder: workOrder,
        status: WorkOrderStatus.completed,
      );

  Future<void> deleteWorkOrder(String id) async {
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderDetailsSections.deleteWorkOrder,
          SectionStatus.running,
        ),
      ),
    );
    final dataState = await _useCases.deleteWorkOrder(id);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(
        state.copyWith(
          annulWorkOrder: true,
          sections: withSection(
            WorkOrderDetailsSections.deleteWorkOrder,
            SectionStatus.success,
          ),
        ),
      );
      await maybePopTopRoute();
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrderDetailsSections.deleteWorkOrder,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
    }
  }

  Future<bool> restoreWorkOrder(String id) async {
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderDetailsSections.restoreWorkOrder,
          SectionStatus.running,
        ),
      ),
    );
    final dataState = await _useCases.restoreWorkOrder(id);
    if (isClosed) return false;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrderDetailsSections.restoreWorkOrder,
            SectionStatus.success,
          ),
        ),
      );
      await loadWorkOrder(id);
      return true;
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrderDetailsSections.restoreWorkOrder,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
      return false;
    }
  }

  Future<void> navigateToCreateUpdateWorkOrder(
    String? workOrderId, {
    AttachmentsCubit? attachmentsCubit,
  }) async {
    final result = await pushRoute<dynamic>(
      CreateUpdateWorkOrderRoute(
        workOrderId: workOrderId,
        attachmentsCubit: attachmentsCubit,
      ),
    );
    if (result == true && workOrderId != null) {
      await loadWorkOrder(workOrderId);
      await attachmentsCubit?.refreshAttachments();
    }
  }

  Future<void> navigateToWorkOrderPendingRequests(
    WorkOrderEntity workOrder,
    String currentUserId,
  ) async {
    await pushRoute(
      WorkOrderPendingRequestsRoute(
        workOrder: workOrder,
        currentUserId: currentUserId,
      ),
    );
  }

  Future<void> loadWorkOrderHistory(String workOrderId) async {
    final dataState = await _useCases.getWorkOrderHistory(workOrderId);
    if (isClosed) return;

    if (dataState is SuccessState<List<WorkOrderHistoryEntity>>) {
      emit(state.copyWith(history: dataState.data ?? []));
    } else {
      showDataStateToast(dataState);
    }
  }

  Future<void> createChangeRequest(WorkOrderChangeRequestEntity request) async {
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderDetailsSections.createChangeRequest,
          SectionStatus.running,
        ),
      ),
    );
    final dataState = await _useCases.createChangeRequest(request);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrderDetailsSections.createChangeRequest,
            SectionStatus.success,
          ),
        ),
      );
      showSuccessToast(
        'Solicitação de alteração enviada com sucesso'.hardcoded,
      );
      await loadWorkOrder(request.workOrderId);
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrderDetailsSections.createChangeRequest,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
    }
  }

  Future<void> reviewChangeRequest(ReviewChangeRequestParams params) async {
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderDetailsSections.reviewChangeRequest,
          SectionStatus.running,
        ),
      ),
    );
    final dataState = await _useCases.reviewChangeRequest(params);
    if (isClosed) return;

    if (dataState is SuccessState<bool> && dataState.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrderDetailsSections.reviewChangeRequest,
            SectionStatus.success,
          ),
        ),
      );
      showSuccessToast(
        'Solicitação de alteração avaliada com sucesso'.hardcoded,
      );
      if (state.workOrder != null) {
        await loadWorkOrder(state.workOrder!.id);
      }
    } else {
      emit(
        state.copyWith(
          sections: withSection(
            WorkOrderDetailsSections.reviewChangeRequest,
            SectionStatus.error,
          ),
        ),
      );
      showDataStateToast(dataState);
    }
  }

  Future<void> navigateToCreateSlaPolicy() async {
    await pushRoute(CreateUpdateSlaPolicyRoute());
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    return super.close();
  }
}
