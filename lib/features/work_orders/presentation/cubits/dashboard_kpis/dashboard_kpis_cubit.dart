import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_kpi_metrics_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/calculate_work_order_kpis_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/kpi_period.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/dashboard_kpis/dashboard_kpis_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit_sections.dart';

part 'dashboard_kpis_state.dart';

@injectable
class DashboardKpisCubit extends BaseCubit<DashboardKpisState> {
  DashboardKpisCubit({required DashboardKpisCubitUseCases useCases})
    : _useCases = useCases,
      super(const DashboardKpisState.initial());

  final DashboardKpisCubitUseCases _useCases;

  void computeKpis(
    List<WorkOrderEntity> workOrders, {
    KpiPeriod? period,
    DateTime? referenceDate,
  }) {
    final activePeriod = period ?? state.selectedPeriod;
    final metrics = _useCases.calculateWorkOrderKpis(
      CalculateWorkOrderKpisParams(
        workOrders: workOrders,
        period: activePeriod,
        referenceDate: referenceDate,
      ),
    );

    emit(
      state.copyWith(
        metrics: metrics,
        selectedPeriod: activePeriod,
        status: StateStatus.loaded,
      ),
    );
  }

  void changePeriod(
    KpiPeriod period,
    List<WorkOrderEntity> workOrders, {
    DateTime? referenceDate,
  }) {
    computeKpis(
      workOrders,
      period: period,
      referenceDate: referenceDate,
    );
  }
}
