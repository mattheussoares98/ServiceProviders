import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

@LazySingleton()
class GetWorkOrderByIdUseCase implements UseCase<WorkOrderEntity, String> {
  GetWorkOrderByIdUseCase({required WorkOrdersRepository workOrdersRepository})
    : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureData<WorkOrderEntity> call(String request) =>
      _workOrdersRepository.getWorkOrderById(request);
}
