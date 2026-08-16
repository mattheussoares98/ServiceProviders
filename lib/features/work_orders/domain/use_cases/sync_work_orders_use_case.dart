import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

/// Triggers delta synchronization for work orders belonging to a company.
@LazySingleton()
class SyncWorkOrdersUseCase implements UseCase<bool, String> {
  SyncWorkOrdersUseCase({required WorkOrdersRepository workOrdersRepository})
    : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureBool call(String request) =>
      _workOrdersRepository.syncWorkOrders(request);
}
