import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/cubits/maintenance_plans/maintenance_plans_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'maintenance_plans_state.dart';

@injectable
class MaintenancePlansCubit extends BaseCubit<MaintenancePlansState> {
  MaintenancePlansCubit({required MaintenancePlansCubitUseCases useCases})
    : _useCases = useCases,
      super(const MaintenancePlansState.initial());

  final MaintenancePlansCubitUseCases _useCases;

  Future<void> loadMaintenancePlans({bool emitLoading = true}) async {
    final companyId = _useCases.getActiveCompanyId();

    if (emitLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

    final result = await _useCases.getMaintenancePlans(companyId);
    if (isClosed) return;

    if (result is SuccessState<List<MaintenancePlanEntity>>) {
      emit(
        state.copyWith(
          maintenancePlans: result.data ?? [],
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
    } else {
      final message =
          result.message ?? 'Erro ao carregar planos de manutenção'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            BaseSections.load,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
    }
  }

  Future<void> navigateToCreateUpdateMaintenancePlan({
    MaintenancePlanEntity? maintenancePlan,
  }) async {
    await pushRoute(
      CreateUpdateMaintenancePlanRoute(maintenancePlan: maintenancePlan),
    );
    await loadMaintenancePlans(emitLoading: false);
  }

  void selectMaintenancePlan(String? id) {
    if (id == null) {
      emit(state.copyWith(annulSelectedMaintenancePlan: true));
      return;
    }

    final plan = state.maintenancePlans
        .cast<MaintenancePlanEntity?>()
        .firstWhereOrNull((e) => e?.id == id);

    if (plan != null) {
      emit(state.copyWith(selectedMaintenancePlan: plan));
    } else {
      emit(state.copyWith(annulSelectedMaintenancePlan: true));
    }
  }

  Future<bool> saveMaintenancePlan(MaintenancePlanEntity plan) async {
    emit(
      state.copyWith(
        sections: withSection(
          MaintenancePlansSections.save,
          SectionStatus.running,
        ),
      ),
    );

    final isUpdate = state.maintenancePlans.any((p) => p.id == plan.id);

    final result = isUpdate
        ? await _useCases.updateMaintenancePlan(plan)
        : await _useCases.createMaintenancePlan(plan);

    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            MaintenancePlansSections.save,
            SectionStatus.success,
          ),
        ),
      );
      await loadMaintenancePlans(emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao salvar plano de manutenção'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            MaintenancePlansSections.save,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> toggleActive(MaintenancePlanEntity plan) async {
    emit(
      state.copyWith(
        sections: withSection(
          MaintenancePlansSections.toggleActive,
          SectionStatus.running,
        ),
      ),
    );

    final updatedPlan = plan.copyWith(
      isActive: !plan.isActive,
      updatedAt: DateTime.now().toUtc(),
    );

    final result = await _useCases.updateMaintenancePlan(updatedPlan);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(
        state.copyWith(
          sections: withSection(
            MaintenancePlansSections.toggleActive,
            SectionStatus.success,
          ),
        ),
      );
      await loadMaintenancePlans(emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao alterar status do plano'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            MaintenancePlansSections.toggleActive,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }

  Future<bool> deleteMaintenancePlan(String id) async {
    emit(
      state.copyWith(
        sections: withSection(
          MaintenancePlansSections.delete,
          SectionStatus.running,
        ),
      ),
    );

    final result = await _useCases.deleteMaintenancePlan(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final updatedPlans = state.maintenancePlans
          .where((p) => p.id != id)
          .toList();
      emit(
        state.copyWith(
          maintenancePlans: updatedPlans,
          annulSelectedMaintenancePlan: state.selectedMaintenancePlan?.id == id,
          sections: withSection(
            MaintenancePlansSections.delete,
            SectionStatus.success,
          ),
        ),
      );
      await loadMaintenancePlans(emitLoading: false);
      return true;
    } else {
      final message =
          result.message ?? 'Erro ao excluir plano de manutenção'.hardcoded;
      emit(
        state.copyWith(
          sections: withSection(
            MaintenancePlansSections.delete,
            SectionStatus.error,
            errorMessage: message,
          ),
        ),
      );
      showErrorToast(message);
      return false;
    }
  }
}
