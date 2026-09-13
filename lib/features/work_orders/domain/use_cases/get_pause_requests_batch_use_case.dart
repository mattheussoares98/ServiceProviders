import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

class GetPauseRequestsBatchParams extends Equatable {
  const GetPauseRequestsBatchParams({
    required this.workOrderIds,
    this.since,
  });

  final List<String> workOrderIds;
  final DateTime? since;

  @override
  List<Object?> get props => [workOrderIds, since];
}

@LazySingleton()
class GetPauseRequestsBatchUseCase
    implements
        UseCase<List<PauseRequestEntity>, GetPauseRequestsBatchParams> {
  const GetPauseRequestsBatchUseCase({
    required PauseRepository pauseRepository,
  }) : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  @override
  FutureData<List<PauseRequestEntity>> call(
    GetPauseRequestsBatchParams params,
  ) => _pauseRepository.getPauseRequestsByWorkOrderIds(
    params.workOrderIds,
    since: params.since,
  );
}
