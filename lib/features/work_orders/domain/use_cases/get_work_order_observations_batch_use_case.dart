import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';

@LazySingleton()
class GetWorkOrderObservationsBatchUseCase
    implements UseCase<List<WorkOrderObservationEntity>, List<String>> {
  const GetWorkOrderObservationsBatchUseCase({
    required WorkOrderObservationsRepository repository,
  }) : _repository = repository;

  final WorkOrderObservationsRepository _repository;

  @override
  FutureList<WorkOrderObservationEntity> call(List<String> request) =>
      _repository.getObservationsByWorkOrderIds(request);
}
