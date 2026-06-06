import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class UpdateWorkOrderUseCase implements UseCase<bool, WorkOrderEntity> {
  UpdateWorkOrderUseCase({required WorkOrdersRepository workOrdersRepository})
      : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureBool call(WorkOrderEntity request) =>
      _workOrdersRepository.updateWorkOrder(request);
}
