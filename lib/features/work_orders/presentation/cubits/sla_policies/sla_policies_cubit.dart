import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/sla_policies/sla_policies_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'sla_policies_state.dart';

@injectable
class SlaPoliciesCubit extends BaseCubit<SlaPoliciesState> {
  SlaPoliciesCubit({required SlaPoliciesCubitUseCases useCases})
    : _useCases = useCases,
      super(const SlaPoliciesState.initial());

  final SlaPoliciesCubitUseCases _useCases;

  Future<void> loadSlaPolicies({bool emitLoading = true}) async {
    final user = _useCases.getSessionUser();

    if (emitLoading) {
      emit(state.copyWith(status: StateStatus.loading));
    }

    final result = await _useCases.getSlaPolicies(user.companyId);
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

  Future<bool> saveSlaPolicy(SlaPolicyEntity policy) async {
    emit(state.copyWith(status: StateStatus.saving));
    final result = await _useCases.createSlaPolicy(policy);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(status: StateStatus.loaded));
      await loadSlaPolicies(emitLoading: false);
      return true;
    } else {
      //TODO test this
      final message =
          result.message ?? 'Erro ao criar política de SLA'.hardcoded;
      emit(
        state.copyWith(status: StateStatus.savingError, errorMessage: message),
      );
      showErrorToast(message);
      return false;
    }
  }
}
