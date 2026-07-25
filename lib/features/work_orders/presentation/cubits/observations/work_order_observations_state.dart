import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

class WorkOrderObservationsState extends BaseState {
  const WorkOrderObservationsState({
    super.status = StateStatus.initial,
    this.observations = const [],
    super.errorMessage,
  });

  final List<WorkOrderObservationEntity> observations;

  @override
  List<Object?> get props => [status, observations, errorMessage];

  WorkOrderObservationsState copyWith({
    StateStatus? status,
    List<WorkOrderObservationEntity>? observations,
    String? errorMessage,
  }) {
    return WorkOrderObservationsState(
      status: status ?? this.status,
      observations: observations ?? this.observations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
