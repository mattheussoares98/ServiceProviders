import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:injectable/injectable.dart';

/// Creates a change request for a closed work order.
@LazySingleton()
class CreateWorkOrderChangeRequestUseCase
    implements UseCase<bool, WorkOrderChangeRequestEntity> {
  CreateWorkOrderChangeRequestUseCase(
      {required WorkOrdersRepository workOrdersRepository})
      : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureBool call(WorkOrderChangeRequestEntity request) =>
      _workOrdersRepository.createChangeRequest(request);
}
