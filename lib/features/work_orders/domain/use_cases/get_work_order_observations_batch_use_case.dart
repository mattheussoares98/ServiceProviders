import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';

class GetWorkOrderObservationsBatchParams {
  const GetWorkOrderObservationsBatchParams({
    required this.workOrderIds,
    this.since,
  });

  final List<String> workOrderIds;
  final DateTime? since;
}

@LazySingleton()
class GetWorkOrderObservationsBatchUseCase
    implements
        UseCase<
          List<WorkOrderObservationEntity>,
          GetWorkOrderObservationsBatchParams
        > {
  const GetWorkOrderObservationsBatchUseCase({
    required WorkOrderObservationsRepository repository,
  }) : _repository = repository;

  final WorkOrderObservationsRepository _repository;

  @override
  FutureList<WorkOrderObservationEntity> call(
    GetWorkOrderObservationsBatchParams params,
  ) => _repository.getObservationsByWorkOrderIds(
    params.workOrderIds,
    since: params.since,
  );
}
