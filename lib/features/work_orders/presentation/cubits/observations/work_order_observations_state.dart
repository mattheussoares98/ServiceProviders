import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

class WorkOrderObservationsState extends BaseState {
  const WorkOrderObservationsState({
    this.observations = const [],
    super.sections,
  });

  final List<WorkOrderObservationEntity> observations;

  @override
  List<Object?> get props => [observations, sections];

  WorkOrderObservationsState copyWith({
    List<WorkOrderObservationEntity>? observations,
    Map<SectionKey, SectionState>? sections,
  }) {
    return WorkOrderObservationsState(
      observations: observations ?? this.observations,
      sections: sections ?? this.sections,
    );
  }
}
