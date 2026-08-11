import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

class WorkOrderObservationsState extends BaseState {
  const WorkOrderObservationsState({
    super.status = StateStatus.initial,
    this.observations = const [],
    super.errorMessage,
    super.sections,
  });

  final List<WorkOrderObservationEntity> observations;

  @override
  List<Object?> get props => [status, observations, errorMessage, sections];

  WorkOrderObservationsState copyWith({
    StateStatus? status,
    List<WorkOrderObservationEntity>? observations,
    String? errorMessage,
    Map<SectionKey, StateStatus>? sections,
  }) {
    return WorkOrderObservationsState(
      status: status ?? this.status,
      observations: observations ?? this.observations,
      errorMessage: errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }
}
