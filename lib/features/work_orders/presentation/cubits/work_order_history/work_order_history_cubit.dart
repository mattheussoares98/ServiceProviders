import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_history/work_order_history_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'work_order_history_state.dart';

@injectable
class WorkOrderHistoryCubit extends BaseCubit<WorkOrderHistoryState> {
  WorkOrderHistoryCubit({required WorkOrderHistoryCubitUseCases useCases})
    : _useCases = useCases,
      super(const WorkOrderHistoryState.initial());

  final WorkOrderHistoryCubitUseCases _useCases;

  Future<void> loadHistory(String workOrderId, {bool showLoading = true}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          sections: withSection(BaseSections.load, SectionStatus.running),
        ),
      );
    }

    final dataState = await _useCases.getWorkOrderHistory(workOrderId);
    if (isClosed) return;

    if (dataState is SuccessState<List<WorkOrderHistoryEntity>>) {
      emit(
        state.copyWith(
          history: dataState.data ?? [],
          sections: withSection(BaseSections.load, SectionStatus.success),
        ),
      );
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
    }
  }

  void setDateRange({DateTime? startDate, DateTime? endDate}) {
    emit(
      state.copyWith(
        startDate: startDate,
        endDate: endDate,
        annulStartDate: startDate == null,
        annulEndDate: endDate == null,
      ),
    );
  }

  void clearDateFilter() {
    emit(
      state.copyWith(
        annulStartDate: true,
        annulEndDate: true,
      ),
    );
  }
}
