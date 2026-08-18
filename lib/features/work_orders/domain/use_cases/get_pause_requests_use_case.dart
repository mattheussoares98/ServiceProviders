import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

class GetPauseRequestsParams extends Equatable {
  const GetPauseRequestsParams({required this.workOrderId, this.status});

  final String workOrderId;
  final PauseRequestStatus? status;

  @override
  List<Object?> get props => [workOrderId, status];
}

@LazySingleton()
class GetPauseRequestsUseCase
    implements UseCase<List<PauseRequestEntity>, GetPauseRequestsParams> {
  GetPauseRequestsUseCase({required PauseRepository pauseRepository})
    : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  @override
  FutureList<PauseRequestEntity> call(GetPauseRequestsParams request) =>
      _pauseRepository.getPauseRequests(
        request.workOrderId,
        status: request.status,
      );
}
