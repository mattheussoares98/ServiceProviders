import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/calculate_work_order_kpis_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/kpi_period.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/dashboard_kpis/dashboard_kpis_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/dashboard_kpis/dashboard_kpis_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

void main() {
  late MockCalculateWorkOrderKpisUseCase mockCalculateWorkOrderKpisUseCase;
  late MockNavigationClient mockNavigationClient;
  late DashboardKpisCubitUseCases useCases;

  setUpAll(() {
    registerFallbackValue(
      const CalculateWorkOrderKpisParams(
        workOrders: [],
        period: KpiPeriod.allTime,
      ),
    );
  });

  setUp(() {
    mockNavigationClient = MockNavigationClient();
    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    mockCalculateWorkOrderKpisUseCase = MockCalculateWorkOrderKpisUseCase();
    useCases = DashboardKpisCubitUseCases(
      calculateWorkOrderKpis: mockCalculateWorkOrderKpisUseCase,
    );
  });

  tearDown(GetIt.I.reset);

  group('DashboardKpisCubit', () {
    final tWorkOrders = EntityFactory.makeWorkOrderEntityList();
    final tMetrics = EntityFactory.makeWorkOrderKpiMetricsEntity();

    test('initial state has empty metrics and last30Days selected', () {
      final cubit = DashboardKpisCubit(useCases: useCases);
      expect(cubit.state.status, StateStatus.initial);
      expect(cubit.state.selectedPeriod, KpiPeriod.last30Days);
      expect(cubit.state.metrics.totalWorkOrders, 0);
    });

    blocTest<DashboardKpisCubit, DashboardKpisState>(
      'computes KPIs and emits loaded state with metrics',
      build: () {
        when(
          () => mockCalculateWorkOrderKpisUseCase.call(any()),
        ).thenReturn(tMetrics);
        return DashboardKpisCubit(useCases: useCases);
      },
      act: (cubit) => cubit.computeKpis(tWorkOrders),
      expect: () => [
        isA<DashboardKpisState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.metrics, 'metrics', tMetrics)
            .having((s) => s.selectedPeriod, 'selectedPeriod', KpiPeriod.last30Days),
      ],
      verify: (_) {
        verify(() => mockCalculateWorkOrderKpisUseCase.call(any())).called(1);
      },
    );

    blocTest<DashboardKpisCubit, DashboardKpisState>(
      'changes period, recomputes KPIs and updates selectedPeriod',
      build: () {
        when(
          () => mockCalculateWorkOrderKpisUseCase.call(any()),
        ).thenReturn(tMetrics);
        return DashboardKpisCubit(useCases: useCases);
      },
      act: (cubit) => cubit.changePeriod(KpiPeriod.last7Days, tWorkOrders),
      expect: () => [
        isA<DashboardKpisState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.metrics, 'metrics', tMetrics)
            .having((s) => s.selectedPeriod, 'selectedPeriod', KpiPeriod.last7Days),
      ],
      verify: (_) {
        verify(
          () => mockCalculateWorkOrderKpisUseCase.call(
            any(
              that: isA<CalculateWorkOrderKpisParams>().having(
                (p) => p.period,
                'period',
                KpiPeriod.last7Days,
              ),
            ),
          ),
        ).called(1);
      },
    );
  });
}
