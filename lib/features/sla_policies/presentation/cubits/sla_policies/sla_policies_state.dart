part of 'sla_policies_cubit.dart';

class SlaPoliciesState extends BaseState {
  const SlaPoliciesState({
    required this.slaPolicies,
    this.selectedSlaPolicy,
    super.status = StateStatus.initial,
    super.errorMessage = '',
    super.sections = const {},
  });

  const SlaPoliciesState.initial()
      : slaPolicies = const [],
        selectedSlaPolicy = null,
        super(
          status: StateStatus.initial,
          errorMessage: '',
          sections: const {},
        );

  final List<SlaPolicyEntity> slaPolicies;
  final SlaPolicyEntity? selectedSlaPolicy;

  SlaPoliciesState copyWith({
    List<SlaPolicyEntity>? slaPolicies,
    SlaPolicyEntity? selectedSlaPolicy,
    bool? annulSelectedSlaPolicy,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
    Map<SectionKey, StateStatus>? sections,
  }) {
    return SlaPoliciesState(
      slaPolicies: slaPolicies ?? this.slaPolicies,
      selectedSlaPolicy: annulSelectedSlaPolicy == true
          ? null
          : selectedSlaPolicy ?? this.selectedSlaPolicy,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
        slaPolicies,
        selectedSlaPolicy,
        status,
        errorMessage,
        sections,
      ];
}
