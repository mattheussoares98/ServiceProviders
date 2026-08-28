import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit_sections.dart';
import 'package:uuid/uuid.dart';

part 'sla_policies_state.dart';

enum SlaPoliciesSection implements SectionKey {
  deleteSlaPolicy,
  saveSlaPolicy,
}

@injectable
class SlaPoliciesCubit extends BaseCubit<SlaPoliciesState> {
  SlaPoliciesCubit({required SlaPoliciesCubitUseCases useCases})
    : _useCases = useCases,
      super(const SlaPoliciesState.initial()) {
    _initRealtime();
  }

  final SlaPoliciesCubitUseCases _useCases;
  StreamSubscription<RealtimeEvent<SlaPolicyEntity>>? _slaSubscription;

  void _initRealtime() {
    final companyId = _useCases.getActiveCompanyId();
    _slaSubscription = _useCases
        .watchSlaPoliciesRealtime(companyId: companyId)
        .listen(_handleRealtimeEvent);
  }

  void _handleRealtimeEvent(RealtimeEvent<SlaPolicyEntity> event) {
    if (isClosed) return;

    final currentPolicies = List<SlaPolicyEntity>.from(state.slaPolicies);

    switch (event.eventType) {
      case RealtimeEventType.insert:
        if (event.entity != null) {
          final index = currentPolicies.indexWhere((p) => p.id == event.id);
          if (index == -1) {
            currentPolicies.insert(0, event.entity!);
          } else {
            currentPolicies[index] = event.entity!;
          }
          emit(state.copyWith(slaPolicies: currentPolicies));
        }
      case RealtimeEventType.update:
        if (event.entity != null) {
          final index = currentPolicies.indexWhere((p) => p.id == event.id);
          if (index != -1) {
            currentPolicies[index] = event.entity!;
          } else {
            currentPolicies.add(event.entity!);
          }
          emit(state.copyWith(slaPolicies: currentPolicies));
        }
      case RealtimeEventType.delete:
        final index = currentPolicies.indexWhere((p) => p.id == event.id);
        if (index != -1) {
          currentPolicies.removeAt(index);
          emit(state.copyWith(slaPolicies: currentPolicies));
        }
    }
  }

  Future<void> loadSlaPolicies({bool emitLoading = true}) async {
    final companyId = _useCases.getActiveCompanyId();

    if (emitLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final result = await _useCases.getSlaPolicies(companyId);
    if (isClosed) return;

    if (result is SuccessState<List<SlaPolicyEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          slaPolicies: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      final message =
          result.message ?? 'Erro ao carregar políticas de SLA'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.loadingError, errorMessage: message),
      );
      showErrorToast(message);
    }
  }

  void selectSlaPolicy(String? id) {
    if (id == null) {
      emit(state.copyWith(annulSelectedSlaPolicy: true));
      return;
    }

    final policy = state.slaPolicies.cast<SlaPolicyEntity?>().firstWhere(
      (element) => element?.id == id,
      orElse: () => null,
    );

    if (policy != null) {
      emit(state.copyWith(selectedSlaPolicy: policy));
    } else {
      emit(state.copyWith(annulSelectedSlaPolicy: true));
    }
  }

  Future<bool> saveSlaPolicy({
    String? id,
    required String name,
    required int targetHours,
    required SlaAppliesTo appliesTo,
    DateTime? createdAt,
  }) async {
    emit(
      state.copyWith(
        sections: withSection(
          SlaPoliciesSection.saveSlaPolicy,
          StateStatus.saving,
        ),
      ),
    );
    final companyId = _useCases.getActiveCompanyId();
    final now = DateTime.now();
    final isEditing = id != null;
    final policy = SlaPolicyEntity(
      id: id ?? const Uuid().v4(),
      companyId: companyId,
      name: name,
      targetHours: targetHours,
      appliesTo: appliesTo,
      createdAt: createdAt ?? now,
      updatedAt: now,
      deletedAt: null,
    );
    final result = isEditing
        ? await _useCases.updateSlaPolicy(policy)
        : await _useCases.createSlaPolicy(policy);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            SlaPoliciesSection.saveSlaPolicy,
            StateStatus.loaded,
          ),
        ),
      );
      await loadSlaPolicies(emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao salvar política de SLA'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            SlaPoliciesSection.saveSlaPolicy,
            StateStatus.savingError,
          ),
          errorMessage: message,
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> deleteSlaPolicy(String id) async {
    emit(
      state.copyWith(
        sections: withSection(
          SlaPoliciesSection.deleteSlaPolicy,
          StateStatus.deleting,
        ),
      ),
    );
    final result = await _useCases.deleteSlaPolicy(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            SlaPoliciesSection.deleteSlaPolicy,
            StateStatus.loaded,
          ),
        ),
      );
      await loadSlaPolicies(emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao excluir política de SLA'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            SlaPoliciesSection.deleteSlaPolicy,
            StateStatus.deletingError,
          ),
          errorMessage: message,
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<void> navigateToCreateUpdateSlaPolicy({
    SlaPolicyEntity? slaPolicy,
  }) async {
    final result = await pushRoute<dynamic>(
      CreateUpdateSlaPolicyRoute(slaPolicy: slaPolicy),
    );
    if (result == true) {
      await loadSlaPolicies();
    }
  }

  @override
  Future<void> close() {
    _slaSubscription?.cancel();
    return super.close();
  }
}
