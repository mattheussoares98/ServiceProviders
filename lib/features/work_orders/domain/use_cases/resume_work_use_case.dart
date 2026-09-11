import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

class ResumeWorkParams {
  const ResumeWorkParams({
    required this.id,
    required this.workOrderId,
    required this.resumedAt,
    required this.resumedById,
  });

  final String id;
  final String workOrderId;
  final DateTime resumedAt;
  final String resumedById;
}

@LazySingleton()
class ResumeWorkUseCase implements UseCase<bool, ResumeWorkParams> {
  ResumeWorkUseCase({required PauseRepository pauseRepository})
    : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  @override
  FutureBool call(ResumeWorkParams request) => _pauseRepository.resumeWork(
    id: request.id,
    workOrderId: request.workOrderId,
    resumedAt: request.resumedAt,
    resumedById: request.resumedById,
  );
}
