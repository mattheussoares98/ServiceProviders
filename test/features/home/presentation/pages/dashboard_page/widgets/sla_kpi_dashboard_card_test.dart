import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/kpi_card/sla_kpi_dashboard_card.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_kpi_metrics_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/dashboard_kpis/dashboard_kpis_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

import '../../../../../../../testing/mocks/entity_factory.dart';

class MockWorkOrdersCubit extends MockCubit<WorkOrdersState>
    implements WorkOrdersCubit {}

class MockDashboardKpisCubit extends MockCubit<DashboardKpisState>
    implements DashboardKpisCubit {}

void main() {
  late MockWorkOrdersCubit mockWorkOrdersCubit;
  late MockDashboardKpisCubit mockDashboardKpisCubit;

  setUp(() {
    mockWorkOrdersCubit = MockWorkOrdersCubit();
    mockDashboardKpisCubit = MockDashboardKpisCubit();

    when(
      () => mockWorkOrdersCubit.state,
    ).thenReturn(const WorkOrdersState.initial());
    when(
      () => mockWorkOrdersCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);
  });

  Widget buildTestWidget() {
    return MaterialApp(
      theme: lightTheme,
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<WorkOrdersCubit>.value(value: mockWorkOrdersCubit),
            BlocProvider<DashboardKpisCubit>.value(
              value: mockDashboardKpisCubit,
            ),
          ],
          child: const SingleChildScrollView(child: SlaKpiDashboardCard()),
        ),
      ),
    );
  }

  group('SlaKpiDashboardCard', () {
    testWidgets('renders KPI section title and placeholder stats when empty', (
      tester,
    ) async {
      when(
        () => mockDashboardKpisCubit.state,
      ).thenReturn(const DashboardKpisState.initial());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('INDICADORES DE SLA & DESEMPENHO'), findsOneWidget);
      expect(find.text('Sem OS concluídas'), findsOneWidget);
      expect(find.text('Sem quebras'), findsOneWidget);
      expect(find.text('Período'), findsOneWidget);
      expect(find.byType(RangeSlider), findsOneWidget);
    });

    testWidgets('renders computed metrics correctly', (tester) async {
      const metrics = WorkOrderKpiMetricsEntity(
        totalWorkOrders: 10,
        completedCount: 8,
        completedWithinSlaCount: 7,
        slaBreachedCount: 1,
        deliveryRate: 87.5,
        breachRate: 12.5,
        mttrMinutes: 90,
        openCount: 1,
        inProgressCount: 1,
        delayedCount: 2,
        pendingApprovalCount: 0,
      );

      when(() => mockDashboardKpisCubit.state).thenReturn(
        const DashboardKpisState(metrics: metrics),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('87,50%'), findsOneWidget);
      expect(find.text('7/8 no prazo'), findsOneWidget);
      expect(find.text('1h, 30m e 0s'), findsOneWidget);
      expect(find.text('12,50%'), findsOneWidget);
      expect(find.text('1 fora do prazo'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders KpiDateRangeSlider with date bounds', (tester) async {
      final tOrders = EntityFactory.makeWorkOrderEntityList();
      when(() => mockWorkOrdersCubit.state).thenReturn(
        const WorkOrdersState.initial().copyWith(workOrders: tOrders),
      );
      when(
        () => mockDashboardKpisCubit.state,
      ).thenReturn(const DashboardKpisState.initial());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RangeSlider), findsOneWidget);
    });
  });
}
