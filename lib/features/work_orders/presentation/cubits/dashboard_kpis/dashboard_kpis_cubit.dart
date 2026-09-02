import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_kpi_metrics_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/calculate_work_order_kpis_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/dashboard_kpis/dashboard_kpis_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'dashboard_kpis_state.dart';

@injectable
class DashboardKpisCubit extends BaseCubit<DashboardKpisState> {
  DashboardKpisCubit({required DashboardKpisCubitUseCases useCases})
    : _useCases = useCases,
      super(const DashboardKpisState.initial());

  final DashboardKpisCubitUseCases _useCases;

  void computeKpis(
    List<WorkOrderEntity> workOrders, {
    DateTime? startDate,
    DateTime? endDate,
    DateTime? referenceDate,
  }) {
    final activeStartDate = startDate ?? state.startDate;
    final activeEndDate = endDate ?? state.endDate;

    final metrics = _useCases.calculateWorkOrderKpis(
      CalculateWorkOrderKpisParams(
        workOrders: workOrders,
        startDate: activeStartDate,
        endDate: activeEndDate,
        referenceDate: referenceDate,
      ),
    );

    emit(
      state.copyWith(
        metrics: metrics,
        startDate: activeStartDate,
        endDate: activeEndDate,
        sections: withSection(BaseSections.load, SectionStatus.success),
      ),
    );
  }

  void changeDateRange(
    DateTime startDate,
    DateTime endDate,
    List<WorkOrderEntity> workOrders, {
    DateTime? referenceDate,
  }) {
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
      999,
    );

    final metrics = _useCases.calculateWorkOrderKpis(
      CalculateWorkOrderKpisParams(
        workOrders: workOrders,
        startDate: startOfDay,
        endDate: endOfDay,
        referenceDate: referenceDate,
      ),
    );

    emit(
      state.copyWith(
        metrics: metrics,
        startDate: startOfDay,
        endDate: endOfDay,
        sections: withSection(BaseSections.load, SectionStatus.success),
      ),
    );
  }
}
