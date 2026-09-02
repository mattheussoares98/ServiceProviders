part of 'pause_workflow_cubit.dart';

class PauseWorkflowState extends BaseState {
  const PauseWorkflowState({
    required this.pauseReasons,
    required this.pauseRequests,
    super.sections = const {},
  });

  const PauseWorkflowState.initial()
    : pauseReasons = const [],
      pauseRequests = const [],
      super(sections: const {});

  final List<PauseReasonEntity> pauseReasons;
  final List<PauseRequestEntity> pauseRequests;

  PauseWorkflowState copyWith({
    List<PauseReasonEntity>? pauseReasons,
    List<PauseRequestEntity>? pauseRequests,
    Map<SectionKey, SectionState>? sections,
  }) {
    return PauseWorkflowState(
      pauseReasons: pauseReasons ?? this.pauseReasons,
      pauseRequests: pauseRequests ?? this.pauseRequests,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [pauseReasons, pauseRequests, sections];
}
