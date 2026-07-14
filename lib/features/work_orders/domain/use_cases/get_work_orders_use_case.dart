import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

class GetWorkOrdersParams {
  const GetWorkOrdersParams({
    required this.companyId,
    this.filter = const WorkOrderFilter(),
    this.pageSize = 20,
    this.offset = 0,
  });

  final String companyId;
  final WorkOrderFilter filter;
  final int pageSize;
  final int offset;
}

@LazySingleton()
class GetWorkOrdersUseCase
    implements UseCase<List<WorkOrderEntity>, GetWorkOrdersParams> {
  GetWorkOrdersUseCase({required WorkOrdersRepository workOrdersRepository})
    : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureList<WorkOrderEntity> call(GetWorkOrdersParams request) =>
      _workOrdersRepository.getWorkOrders(
        request.companyId,
        filter: request.filter,
        pageSize: request.pageSize,
        offset: request.offset,
      );
}
