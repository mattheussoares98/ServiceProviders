import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:injectable/injectable.dart';

/// Fetches all pending change requests for a company.
@LazySingleton()
class GetWorkOrderChangeRequestsUseCase
    implements UseCase<List<WorkOrderChangeRequestEntity>, String> {
  GetWorkOrderChangeRequestsUseCase(
      {required WorkOrdersRepository workOrdersRepository})
      : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureList<WorkOrderChangeRequestEntity> call(String request) =>
      _workOrdersRepository.getChangeRequests(request);
}
