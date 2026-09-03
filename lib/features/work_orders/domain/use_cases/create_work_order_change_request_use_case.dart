import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

/// Creates a change request for a closed work order.
@LazySingleton()
class CreateWorkOrderChangeRequestUseCase
    implements UseCase<bool, WorkOrderChangeRequestEntity> {
  CreateWorkOrderChangeRequestUseCase({
    required WorkOrdersRepository workOrdersRepository,
  }) : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureBool call(WorkOrderChangeRequestEntity request) =>
      _workOrdersRepository.createChangeRequest(request);
}
