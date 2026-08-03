import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/cancel_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_completion_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/review_pause_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'pause_workflow_state.dart';

@injectable
class PauseWorkflowCubit extends BaseCubit<PauseWorkflowState> {
  PauseWorkflowCubit({required PauseWorkflowCubitUseCases useCases})
    : _useCases = useCases,
      super(const PauseWorkflowState.initial());

  final PauseWorkflowCubitUseCases _useCases;

  Future<void> loadPauseReasons(String companyId) async {
    emit(state.copyWith(status: StateStatus.loading));
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

  Future<void> loadSectors(String companyId) async {
    final result = await _useCases.getSectors(companyId);
    if (isClosed) return;

    if (result is SuccessState<List<SectorEntity>>) {
      emit(state.copyWith(sectors: result.data ?? []));
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

  Future<bool> requestPause(PauseRequestEntity request) async {
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

  Future<bool> cancelPause({
    required String id,
    required DateTime resumedAt,
    required String workOrderId,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.cancelPause(
      CancelPauseParams(id: id, resumedAt: resumedAt),
    );
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      await loadPauseRequests(workOrderId);
      return true;
    } else {
      final message = result.message ?? 'Erro ao cancelar pausa'.hardcoded;
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
    String? reviewObservation,
    String? reasonId,
  }) async {
    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.reviewPause(
      ReviewPauseParams(
        id: id,
        status: status,
        reviewedById: reviewedById,
        reviewObservation: reviewObservation,
        reasonId: reasonId,
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

  Future<bool> requestCompletion(PauseRequestEntity request) async {
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
  }) async {
    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.reviewCompletion(
      ReviewCompletionParams(
        id: id,
        status: status,
        reviewedById: reviewedById,
        reviewObservation: reviewObservation,
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
