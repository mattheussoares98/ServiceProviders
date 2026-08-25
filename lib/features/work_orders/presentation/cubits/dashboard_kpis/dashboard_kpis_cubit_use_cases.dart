import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/calculate_work_order_kpis_use_case.dart';

@LazySingleton()
class DashboardKpisCubitUseCases {
  const DashboardKpisCubitUseCases({
    required this.calculateWorkOrderKpis,
  });

  final CalculateWorkOrderKpisUseCase calculateWorkOrderKpis;
}
