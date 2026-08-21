import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

class GetProviderWorkOrdersParams {
  const GetProviderWorkOrdersParams({
    required this.serviceProviderCompanyIds,
    this.filter = const WorkOrderFilter(),
    this.pageSize = 50,
    this.offset = 0,
  });

  /// Every provider company the signed-in user belongs to. The result spans all
  /// of them unless [filter] narrows the selection.
  final List<String> serviceProviderCompanyIds;
  final WorkOrderFilter filter;
  final int pageSize;
  final int offset;
}

@LazySingleton()
class GetProviderWorkOrdersUseCase
    implements UseCase<List<WorkOrderEntity>, GetProviderWorkOrdersParams> {
  GetProviderWorkOrdersUseCase({
    required WorkOrdersRepository workOrdersRepository,
  }) : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureList<WorkOrderEntity> call(GetProviderWorkOrdersParams request) =>
      _workOrdersRepository.getProviderWorkOrders(
        request.serviceProviderCompanyIds,
        filter: request.filter,
        pageSize: request.pageSize,
        offset: request.offset,
      );
}
