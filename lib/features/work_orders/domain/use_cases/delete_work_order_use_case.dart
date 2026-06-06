import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:injectable/injectable.dart';

/// Soft-deletes a work order by its ID.
@LazySingleton()
class DeleteWorkOrderUseCase implements UseCase<bool, String> {
  DeleteWorkOrderUseCase({required WorkOrdersRepository workOrdersRepository})
      : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureBool call(String request) =>
      _workOrdersRepository.deleteWorkOrder(request);
}
