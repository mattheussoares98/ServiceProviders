part of 'pause_workflow_cubit.dart';

class PauseWorkflowState extends BaseState {
  const PauseWorkflowState({
    required this.pauseReasons,
    required this.pauseRequests,
    super.status = DataStatus.initial,
    super.errorMessage = '',
    super.sections = const {},
  });

  const PauseWorkflowState.initial()
    : pauseReasons = const [],
      pauseRequests = const [],
      super(status: DataStatus.initial, errorMessage: '', sections: const {});

  final List<PauseReasonEntity> pauseReasons;
  final List<PauseRequestEntity> pauseRequests;

  PauseWorkflowState copyWith({
    List<PauseReasonEntity>? pauseReasons,
    List<PauseRequestEntity>? pauseRequests,
    DataStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
    Map<SectionKey, SectionStatus>? sections,
  }) {
    return PauseWorkflowState(
      pauseReasons: pauseReasons ?? this.pauseReasons,
      pauseRequests: pauseRequests ?? this.pauseRequests,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    pauseReasons,
    pauseRequests,
    status,
    errorMessage,
    sections,
  ];
}
