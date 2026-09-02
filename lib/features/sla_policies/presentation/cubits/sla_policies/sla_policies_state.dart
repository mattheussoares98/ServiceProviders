part of 'sla_policies_cubit.dart';

class SlaPoliciesState extends BaseState {
  const SlaPoliciesState({
    required this.slaPolicies,
    this.selectedSlaPolicy,
    super.sections = const {},
  });

  const SlaPoliciesState.initial()
    : slaPolicies = const [],
      selectedSlaPolicy = null,
      super(sections: const {});

  final List<SlaPolicyEntity> slaPolicies;
  final SlaPolicyEntity? selectedSlaPolicy;

  SlaPoliciesState copyWith({
    List<SlaPolicyEntity>? slaPolicies,
    SlaPolicyEntity? selectedSlaPolicy,
    bool? annulSelectedSlaPolicy,
    Map<SectionKey, SectionState>? sections,
  }) {
    return SlaPoliciesState(
      slaPolicies: slaPolicies ?? this.slaPolicies,
      selectedSlaPolicy: annulSelectedSlaPolicy == true
          ? null
          : selectedSlaPolicy ?? this.selectedSlaPolicy,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    slaPolicies,
    selectedSlaPolicy,
    sections,
  ];
}
