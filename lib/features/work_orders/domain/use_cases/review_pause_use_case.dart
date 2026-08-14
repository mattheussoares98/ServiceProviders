import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

class ReviewPauseParams {
  const ReviewPauseParams({
    required this.id,
    required this.workOrderId,
    required this.status,
    required this.reviewedById,
    this.reviewObservation,
    this.reasonId,
    this.responsibility,
  });

  final String id;
  final String workOrderId;
  final PauseRequestStatus status;
  final String reviewedById;
  final String? reviewObservation;
  final String? reasonId;
  final PauseResponsibility? responsibility;
}

@LazySingleton()
class ReviewPauseUseCase implements UseCase<bool, ReviewPauseParams> {
  ReviewPauseUseCase({required PauseRepository pauseRepository})
    : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  @override
  FutureBool call(ReviewPauseParams request) => _pauseRepository.reviewPause(
    id: request.id,
    workOrderId: request.workOrderId,
    status: request.status,
    reviewedById: request.reviewedById,
    reviewObservation: request.reviewObservation,
    reasonId: request.reasonId,
    responsibility: request.responsibility,
  );
}
