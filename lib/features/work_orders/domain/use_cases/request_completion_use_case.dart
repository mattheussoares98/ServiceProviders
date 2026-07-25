import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

@LazySingleton()
class RequestCompletionUseCase implements UseCase<bool, PauseRequestEntity> {
  RequestCompletionUseCase({required PauseRepository pauseRepository})
      : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  @override
  FutureBool call(PauseRequestEntity request) =>
      _pauseRepository.requestPause(request);
}
