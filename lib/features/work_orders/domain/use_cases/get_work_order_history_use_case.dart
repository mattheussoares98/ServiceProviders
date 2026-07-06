import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

/// Fetches the history log for a specific work order.
@LazySingleton()
class GetWorkOrderHistoryUseCase
    implements UseCase<List<WorkOrderHistoryEntity>, String> {
  GetWorkOrderHistoryUseCase({
    required WorkOrdersRepository workOrdersRepository,
  }) : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureList<WorkOrderHistoryEntity> call(String request) =>
      _workOrdersRepository.getWorkOrderHistory(request);
}
