part of 'pause_workflow_cubit.dart';

class PauseWorkflowState extends BaseState {
  const PauseWorkflowState({
    required this.pauseReasons,
    required this.pauseRequests,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const PauseWorkflowState.initial()
      : pauseReasons = const [],
        pauseRequests = const [],
        super(status: StateStatus.initial, errorMessage: '');

  final List<PauseReasonEntity> pauseReasons;
  final List<PauseRequestEntity> pauseRequests;

  PauseWorkflowState copyWith({
    List<PauseReasonEntity>? pauseReasons,
    List<PauseRequestEntity>? pauseRequests,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return PauseWorkflowState(
      pauseReasons: pauseReasons ?? this.pauseReasons,
      pauseRequests: pauseRequests ?? this.pauseRequests,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        pauseReasons,
        pauseRequests,
        status,
        errorMessage,
      ];
}
