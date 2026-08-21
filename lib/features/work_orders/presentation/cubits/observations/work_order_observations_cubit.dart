import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/observations/work_order_observations_state.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit_sections.dart';
import 'package:uuid/uuid.dart';

enum WorkOrderObservationsSection implements SectionKey { deleteObservation }

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
      final profile = await _resolveProviderProfile(
        workOrder.serviceProviderCompanyId,
      );
      if (profile == null) {
        emit(
          state.copyWith(
            status: StateStatus.savingError,
            errorMessage: 'Perfil de prestador não encontrado.'.hardcoded,
          ),
        );
        return false;
      }
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    emit(state.copyWith(status: StateStatus.saving));
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

  /// The provider profile of the session user inside the provider company that
  /// the work order is assigned to.
  Future<ServiceProviderProfileEntity?> _resolveProviderProfile(
    String? serviceProviderCompanyId,
  ) async {
    final user = _useCases.getSessionUser();
    if (user.id.isEmpty) return null;

    final result = await _useCases.getServiceProviderProfilesByAuthUser(
      user.id,
    );
    if (result is! SuccessState<List<ServiceProviderProfileEntity>>) {
      return null;
    }

    final profiles = result.data ?? const <ServiceProviderProfileEntity>[];
    return profiles.firstWhereOrNull(
          (e) => e.serviceProviderCompanyId == serviceProviderCompanyId,
        ) ??
        profiles.firstOrNull;
  }

  Future<bool> deleteObservation(String observationId) async {
    emit(
      state.copyWith(
        sections: withSection(
          WorkOrderObservationsSection.deleteObservation,
          StateStatus.deleting,
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
            status: StateStatus.loaded,
            observations: updatedList,
            sections: withSection(
              WorkOrderObservationsSection.deleteObservation,
              StateStatus.loaded,
            ),
          ),
        );
        return true;
      case FailureState(:final message):
        emit(
          state.copyWith(
            status: StateStatus.deletingError,
            errorMessage: message,
            sections: withSection(
              WorkOrderObservationsSection.deleteObservation,
              StateStatus.deletingError,
            ),
          ),
        );
        showErrorToast(message);
        return false;
      case LoadingState():
        emit(
          state.copyWith(
            sections: withSection(
              WorkOrderObservationsSection.deleteObservation,
              StateStatus.loaded,
            ),
          ),
        );
        return false;
    }
  }
}
