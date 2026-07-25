import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_state.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import 'package:uuid/uuid.dart';

@injectable
class WorkOrderObservationsCubit extends BaseCubit<WorkOrderObservationsState> {
  WorkOrderObservationsCubit({
    required WorkOrderObservationsCubitUseCases useCases,
  }) : _useCases = useCases,
       super(const WorkOrderObservationsState());

  final WorkOrderObservationsCubitUseCases _useCases;

  Future<void> fetchObservations(String workOrderId) async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.getObservations(workOrderId);
    switch (result) {
      case SuccessState(:final data):
        final list = List<WorkOrderObservationEntity>.from(data!);
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(state.copyWith(status: StateStatus.loaded, observations: list));
      case FailureState(:final message):
        emit(
          state.copyWith(
            status: StateStatus.loadingError,
            errorMessage: message,
          ),
        );
      case LoadingState():
        break;
    }
  }

  Future<bool> createObservation({
    required String companyId,
    required String workOrderId,
    required String authorId,
    required String authorName,
    required String content,
  }) async {
    final newObservation = WorkOrderObservationEntity(
      id: const Uuid().v4(),
      companyId: companyId,
      workOrderId: workOrderId,
      authorId: authorId,
      authorName: authorName,
      content: content.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await _useCases.createObservation(newObservation);
    switch (result) {
      case SuccessState(:final data):
        final updatedList = <WorkOrderObservationEntity>[
          data!,
          ...state.observations,
        ];
        emit(
          state.copyWith(status: StateStatus.loaded, observations: updatedList),
        );
        return true;
      case FailureState(:final message):
        emit(
          state.copyWith(
            status: StateStatus.savingError,
            errorMessage: message,
          ),
        );
        return false;
      case LoadingState():
        return false;
    }
  }

  Future<bool> deleteObservation(String observationId) async {
    final result = await _useCases.deleteObservation(observationId);
    switch (result) {
      case SuccessState():
        final updatedList = state.observations
            .where((obs) => obs.id != observationId)
            .toList();
        emit(
          state.copyWith(status: StateStatus.loaded, observations: updatedList),
        );
        return true;
      case FailureState(:final message):
        emit(
          state.copyWith(
            status: StateStatus.deletingError,
            errorMessage: message,
          ),
        );
        return false;
      case LoadingState():
        return false;
    }
  }
}
