import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

class ReviewCompletionParams {
  const ReviewCompletionParams({
    required this.id,
    required this.status,
    required this.reviewedById,
    this.reviewObservation,
    this.responsibility,
  });

  final String id;
  final PauseRequestStatus status;
  final String reviewedById;
  final String? reviewObservation;
  final PauseResponsibility? responsibility;
}

@LazySingleton()
class ReviewCompletionUseCase implements UseCase<bool, ReviewCompletionParams> {
  ReviewCompletionUseCase({required PauseRepository pauseRepository})
      : _pauseRepository = pauseRepository;

  final PauseRepository _pauseRepository;

  @override
  FutureBool call(ReviewCompletionParams request) => _pauseRepository.reviewPause(
        id: request.id,
        status: request.status,
        reviewedById: request.reviewedById,
        reviewObservation: request.reviewObservation,
        responsibility: request.responsibility,
      );
}

