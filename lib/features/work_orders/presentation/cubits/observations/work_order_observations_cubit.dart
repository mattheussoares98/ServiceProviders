import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_state.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit_sections.dart';
import 'package:uuid/uuid.dart';

enum WorkOrderObservationsSections implements SectionKey {
  saveObservation,
  deleteObservation,
}

@injectable
class WorkOrderObservationsCubit extends BaseCubit<WorkOrderObservationsState> {
  WorkOrderObservationsCubit({
    required WorkOrderObservationsCubitUseCases useCases,
  }) : _useCases = useCases,
       super(const WorkOrderObservationsState());

  final WorkOrderObservationsCubitUseCases _useCases;

  Future<void> fetchObservations(String workOrderId) async {
    emit(state.copyWith(status: DataStatus.loading));
    final result = await _useCases.getObservations(workOrderId);
    switch (result) {
      case SuccessState(:final data):
        final list = List<WorkOrderObservationEntity>.from(data!)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        emit(state.copyWith(status: DataStatus.loaded, observations: list));
      case FailureState(:final message):
        emit(
          state.copyWith(
            status: DataStatus.loadingError,
            errorMessage: message,
          ),
        );
      case LoadingState():
        break;
    }
  }

  /// Authorship points at one of two identity tables. A provider has no
  /// `user_profiles` row, so writing `author_id` there violates the foreign
  /// key; they are recorded through their `service_provider_profiles` row
  /// instead. The tenant comes from the work order, never from the session:
  /// in provider mode the session company is the provider's own employer.
  Future<bool> createObservation({
    required WorkOrderEntity workOrder,
    required String content,
  }) async {
    final user = _useCases.getSessionUser();
    final isProviderMode =
        AppMode.fromName(_useCases.getSelectedMode()) == AppMode.provider;

    String? authorId = user.id;
    String? authorProviderProfileId;
    var authorName = user.name;

    if (isProviderMode) {
      final profileResult = await _useCases.getSessionProviderProfile(
        workOrder.serviceProviderCompanyId,
      );
      if (profileResult is! SuccessState<ServiceProviderProfileEntity> ||
          profileResult.data == null) {
        emit(
          state.copyWith(
            sections: withSection(
              WorkOrderObservationsSections.saveObservation,
              SectionStatus.error,
            ),
            errorMessage: profileResult.message,
          ),
        );
        return false;
      }
      final profile = profileResult.data!;
      authorId = null;
      authorProviderProfileId = profile.id;
      authorName = profile.name;
    }

    final newObservation = WorkOrderObservationEntity(
      id: const Uuid().v4(),
      companyId: workOrder.companyId,
      workOrderId: workOrder.id,
      authorId: authorId,
      authorProviderProfileId: authorProviderProfileId,
      authorName: authorName,
      content: content.trim(),
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderObservationsSections.saveObservation,
          SectionStatus.running,
        ),
      ),
    );
    final result = await _useCases.createObservation(newObservation);
    switch (result) {
      case SuccessState(:final data):
        final updatedList = <WorkOrderObservationEntity>[
          data!,
          ...state.observations,
        ];
        emit(
          state.copyWith(
            observations: updatedList,
            sections: withSection(
              WorkOrderObservationsSections.saveObservation,
              SectionStatus.success,
            ),
          ),
        );
        return true;
      case FailureState(:final message):
        emit(
          state.copyWith(
            sections: withSection(
              WorkOrderObservationsSections.saveObservation,
              SectionStatus.error,
            ),
            errorMessage: message,
          ),
        );
        return false;
      case LoadingState():
        return false;
    }
  }

  Future<bool> deleteObservation(String observationId) async {
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderObservationsSections.deleteObservation,
          SectionStatus.running,
        ),
      ),
    );

    final result = await _useCases.deleteObservation(observationId);
    switch (result) {
      case SuccessState():
        final updatedList = state.observations
            .where((obs) => obs.id != observationId)
            .toList();
        emit(
          state.copyWith(
            observations: updatedList,
            sections: withSection(
              WorkOrderObservationsSections.deleteObservation,
              SectionStatus.success,
            ),
          ),
        );
        return true;
      case FailureState(:final message):
        emit(
          state.copyWith(
            sections: withSection(
              WorkOrderObservationsSections.deleteObservation,
              SectionStatus.error,
            ),
            errorMessage: message,
          ),
        );
        showErrorToast(message);
        return false;
      case LoadingState():
        return false;
    }
  }
}
