import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches the history log for a specific work order.
@LazySingleton()
class GetWorkOrderHistoryUseCase
    implements UseCase<List<WorkOrderHistoryEntity>, String> {
  GetWorkOrderHistoryUseCase(
      {required WorkOrdersRepository workOrdersRepository})
      : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureList<WorkOrderHistoryEntity> call(String request) =>
      _workOrdersRepository.getWorkOrderHistory(request);
}
