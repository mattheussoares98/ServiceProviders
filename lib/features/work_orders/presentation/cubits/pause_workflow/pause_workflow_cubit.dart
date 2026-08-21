import 'dart:async';

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/has_permission_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_pause_requests_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:uuid/uuid.dart';

part 'pause_workflow_state.dart';

@injectable
class PauseWorkflowCubit extends BaseCubit<PauseWorkflowState> {
  PauseWorkflowCubit({required PauseWorkflowCubitUseCases useCases})
    : _useCases = useCases,
      super(const PauseWorkflowState.initial());

  final PauseWorkflowCubitUseCases _useCases;

  Future<void> loadPauseReasons([bool force = false]) async {
    if (!force && state.pauseReasons.isNotEmpty) return;
    emit(state.copyWith(status: StateStatus.loading));

    final companyId = _useCases.getActiveCompanyId();

    final result = await _useCases.getPauseReasons(companyId);
    if (isClosed) return;

    if (result is SuccessState<List<PauseReasonEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          pauseReasons: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final message =
          result.message ?? 'Erro ao carregar motivos de pausa'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
    }
  }

  Future<void> loadPauseRequests(
    String workOrderId, {
    PauseRequestStatus? status,
  }) async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.getPauseRequests(
      GetPauseRequestsParams(workOrderId: workOrderId, status: status),
    );
    if (isClosed) return;

    if (result is SuccessState<List<PauseRequestEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          pauseRequests: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final message =
          result.message ?? 'Erro ao carregar solicitações de pausa'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
    }
  }

  PauseRequestEntity? get activePauseRequest {
    return state.pauseRequests.firstWhereOrNull(
      (r) =>
          r.eventType == PauseEventType.pause &&
          r.resumedAt == null &&
          r.status != PauseRequestStatus.rejected &&
          r.status != PauseRequestStatus.cancelled,
    );
  }

  PauseRequestEntity? get pendingCompletionRequest {
    return state.pauseRequests.firstWhereOrNull(
      (r) =>
          r.eventType == PauseEventType.completion &&
          r.status == PauseRequestStatus.pending,
    );
  }

  bool get hasPendingPauses {
    return state.pauseRequests.any(
      (r) =>
          r.eventType == PauseEventType.pause &&
          r.status == PauseRequestStatus.pending,
    );
  }

  bool get hasPendingCompletions {
    return state.pauseRequests.any(
      (r) =>
          r.eventType == PauseEventType.completion &&
          r.status == PauseRequestStatus.pending,
    );
  }

  Future<bool> _canDirectlyPause() async {
    final permResult = await _useCases.hasPermission(
      const HasPermissionParams(
        permission: ActionPermission.workOrderSubAction(
          WorkOrderSubAction.managePendingRequests,
        ),
      ),
    );
    return permResult is SuccessState<bool> && permResult.data == true;
  }

  Future<bool> requestPause({
    required String workOrderId,
    required WorkOrdersCubit workOrdersCubit,
    PauseResponsibility responsibility = PauseResponsibility.provider,
    String? reasonId,
    String? customReason,
    String? observation,
    String? sectorId,
    bool affectsSla = true,
  }) async {
    if ((reasonId?.isEmpty ?? true) && (customReason?.trim().isEmpty ?? true)) {
      final message = 'Informe o motivo da pausa'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }

    if (hasPendingCompletions) {
      final message =
          'Existe uma solicitação de conclusão pendente para esta ordem de serviço'
              .hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }

    final currentUserId = _useCases.getSessionUser().id;
    final isDirectPause = await _canDirectlyPause();
    final initialStatus = isDirectPause
        ? PauseRequestStatus.approved
        : PauseRequestStatus.pending;
    final reviewedById = isDirectPause ? currentUserId : null;
    final companyId = _useCases.getActiveCompanyId();

    final now = DateTime.now();
    final request = PauseRequestEntity(
      id: const Uuid().v4(),
      companyId: companyId,
      workOrderId: workOrderId,
      requestedById: currentUserId,
      reasonId: reasonId,
      customReason: customReason,
      observation: observation,
      responsibility: responsibility,
      sectorId: sectorId,
      status: initialStatus,
      pausedAt: now,
      affectsSla: affectsSla,
      createdAt: now,
      updatedAt: now,
      resumedAt: null,
      reviewObservation: null,
      reviewedById: reviewedById,
    );

    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.requestPause(request);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      if (isDirectPause) {
        workOrdersCubit.updateLocalWorkOrderStatus(
          workOrderId,
          WorkOrderStatus.onHold,
          syncRemotely: true,
        );
      } else {
        unawaited(
          workOrdersCubit.loadWorkOrdersAndChangeRequests(showLoading: false),
        );
      }
      await loadPauseRequests(request.workOrderId);
      return true;
    } else {
      final message = result.message ?? 'Erro ao solicitar pausa'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> reviewPause({
    required String id,
    required PauseRequestStatus status,
    required String workOrderId,
    required PauseResponsibility responsibility,
    String? reviewObservation,
    String? reasonId,
    String? reviewedById,
  }) async {
    final currentUserId = reviewedById ?? _useCases.getSessionUser().id;
    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.reviewPause(
      ReviewPauseParams(
        id: id,
        workOrderId: workOrderId,
        status: status,
        reviewedById: currentUserId,
        reviewObservation: reviewObservation,
        reasonId: reasonId,
        responsibility: responsibility,
      ),
    );
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      await loadPauseRequests(workOrderId);
      return true;
    } else {
      final message = result.message ?? 'Erro ao revisar pausa'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> _canDirectlyComplete() async {
    final permResult = await _useCases.hasPermission(
      const HasPermissionParams(
        permission: ActionPermission.workOrderSubAction(
          WorkOrderSubAction.managePendingRequests,
        ),
      ),
    );
    return permResult is SuccessState<bool> && permResult.data == true;
  }

  Future<bool> requestCompletion({
    required String workOrderId,
    required String customReason,
    required WorkOrdersCubit workOrdersCubit,
    String? observation,
    String? sectorId,
  }) async {
    if (customReason.trim().isEmpty) {
      final message = 'Informe a justificativa de conclusão'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }

    if (hasPendingCompletions) {
      final message =
          'Já existe uma solicitação de conclusão pendente para esta ordem de serviço'
              .hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }

    final currentUserId = _useCases.getSessionUser().id;
    final isDirectComplete = await _canDirectlyComplete();
    final initialStatus = isDirectComplete
        ? PauseRequestStatus.approved
        : PauseRequestStatus.pending;
    final reviewedById = isDirectComplete ? currentUserId : null;
    final companyId = _useCases.getActiveCompanyId();
    final now = DateTime.now();
    final request = PauseRequestEntity(
      id: const Uuid().v4(),
      companyId: companyId,
      workOrderId: workOrderId,
      requestedById: currentUserId,
      eventType: PauseEventType.completion,
      customReason: customReason,
      observation: observation,
      sectorId: sectorId,
      status: initialStatus,
      pausedAt: now,
      affectsSla: false,
      createdAt: now,
      updatedAt: now,
      reasonId: null,
      resumedAt: null,
      reviewObservation: null,
      reviewedById: reviewedById,
    );

    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.requestCompletion(request);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      workOrdersCubit.updateLocalWorkOrderStatus(
        workOrderId,
        isDirectComplete
            ? WorkOrderStatus.completed
            : WorkOrderStatus.pendingConclusionApproval,
        syncRemotely: true,
      );
      await loadPauseRequests(request.workOrderId);
      return true;
    } else {
      final message = result.message ?? 'Erro ao solicitar conclusão'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> reviewCompletion({
    required String id,
    required PauseRequestStatus status,
    required String workOrderId,
    String? reviewObservation,
    String? completionReason,
    String? completionSectorId,
    String? reviewedById,
  }) async {
    final currentUserId = reviewedById ?? _useCases.getSessionUser().id;
    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.reviewCompletion(
      ReviewCompletionParams(
        id: id,
        workOrderId: workOrderId,
        status: status,
        reviewedById: currentUserId,
        reviewObservation: reviewObservation,
        completionReason: completionReason,
        completionSectorId: completionSectorId,
      ),
    );
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      await loadPauseRequests(workOrderId);
      return true;
    } else {
      final message =
          result.message ??
          'Erro ao revisar solicitação de conclusão'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }
}
