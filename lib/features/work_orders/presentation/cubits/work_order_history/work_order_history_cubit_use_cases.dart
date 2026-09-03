import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_work_order_history_use_case.dart';

@LazySingleton()
class WorkOrderHistoryCubitUseCases {
  const WorkOrderHistoryCubitUseCases({
    required this.getWorkOrderHistory,
  });

  final GetWorkOrderHistoryUseCase getWorkOrderHistory;
}
