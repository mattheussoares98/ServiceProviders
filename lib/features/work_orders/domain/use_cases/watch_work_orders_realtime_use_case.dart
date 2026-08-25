import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

@LazySingleton()
class WatchWorkOrdersRealtimeUseCase {
  const WatchWorkOrdersRealtimeUseCase({
    required WorkOrdersRepository workOrdersRepository,
  }) : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  Stream<RealtimeEvent<WorkOrderEntity>> call({String? companyId}) =>
      _workOrdersRepository.watchRealtimeWorkOrders(companyId: companyId);
}
