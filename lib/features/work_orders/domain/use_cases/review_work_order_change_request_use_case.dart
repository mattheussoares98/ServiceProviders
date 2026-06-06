import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/change_request_status.dart';
import 'package:clean_architecture/features/work_orders/domain/repositories/work_orders_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

/// Parameter object for reviewing a change request.
class ReviewChangeRequestParams extends Equatable {
  const ReviewChangeRequestParams({
    required this.id,
    required this.status,
    this.rejectionReason,
    required this.reviewedById,
  });

  final String id;
  final ChangeRequestStatus status;
  final String? rejectionReason;
  final String reviewedById;

  @override
  List<Object?> get props => [id, status, rejectionReason, reviewedById];
}

/// Approves or rejects a change request for a closed work order.
@LazySingleton()
class ReviewWorkOrderChangeRequestUseCase {
  ReviewWorkOrderChangeRequestUseCase(
      {required WorkOrdersRepository workOrdersRepository})
      : _workOrdersRepository = workOrdersRepository;

  final WorkOrdersRepository _workOrdersRepository;

  FutureBool call(ReviewChangeRequestParams params) =>
      _workOrdersRepository.reviewChangeRequest(
        id: params.id,
        status: params.status,
        rejectionReason: params.rejectionReason,
        reviewedById: params.reviewedById,
      );
}
