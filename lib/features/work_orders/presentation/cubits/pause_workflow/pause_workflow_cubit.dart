import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit_use_cases.dart';
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

  Future<void> loadPauseRequests(String workOrderId) async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.getPauseRequests(workOrderId);
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

  Future<bool> requestPause({
    required String companyId,
    required String workOrderId,
    required String requestedById,
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

    if (activePauseRequest != null) {
      final message =
          'Já existe uma pausa ativa ou pendente para esta ordem de serviço'
              .hardcoded;
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

    final now = DateTime.now();
    final request = PauseRequestEntity(
      id: const Uuid().v4(),
      companyId: companyId,
      workOrderId: workOrderId,
      requestedById: requestedById,
      reasonId: reasonId,
      customReason: customReason,
      observation: observation,
      responsibility: responsibility,
      sectorId: sectorId,
      status: PauseRequestStatus.pending,
      pausedAt: now,
      affectsSla: affectsSla,
      createdAt: now,
      updatedAt: now,
      resumedAt: null,
      reviewObservation: null,
      reviewedById: null,
    );

    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.requestPause(request);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
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
    required String reviewedById,
    required String workOrderId,
    required PauseResponsibility responsibility,
    String? reviewObservation,
    String? reasonId,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.reviewPause(
      ReviewPauseParams(
        id: id,
        workOrderId: workOrderId,
        status: status,
        reviewedById: reviewedById,
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

  Future<bool> requestCompletion({
    required String companyId,
    required String workOrderId,
    required String requestedById,
    required String customReason,
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

    final now = DateTime.now();
    final request = PauseRequestEntity(
      id: const Uuid().v4(),
      companyId: companyId,
      workOrderId: workOrderId,
      requestedById: requestedById,
      eventType: PauseEventType.completion,
      customReason: customReason,
      observation: observation,
      sectorId: sectorId,
      status: PauseRequestStatus.pending,
      pausedAt: now,
      affectsSla: false,
      createdAt: now,
      updatedAt: now,
      reasonId: null,
      resumedAt: null,
      reviewObservation: null,
      reviewedById: null,
    );

    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.requestCompletion(request);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
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
    required String reviewedById,
    required String workOrderId,
    String? reviewObservation,
    String? completionReason,
    String? completionSectorId,
  }) async {
    if (status == PauseRequestStatus.approved && hasPendingPauses) {
      final message =
          'Existem solicitações de pausa pendentes. Avalie as pausas primeiro'
              .hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }

    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.reviewCompletion(
      ReviewCompletionParams(
        id: id,
        workOrderId: workOrderId,
        status: status,
        reviewedById: reviewedById,
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
