part of 'onboarding_cubit.dart';

final class OnboardingState extends BaseState {
  const OnboardingState({
    this.currentStep = 0,
    this.companyName = '',
    this.document = '',
    this.workType = WorkType.internalOnly,
    super.sections,
  });

  const OnboardingState.initial()
    : currentStep = 0,
      companyName = '',
      document = '',
      workType = WorkType.internalOnly,
      super();

  final int currentStep;
  final String companyName;
  final String document;
  final WorkType workType;

  OnboardingState copyWith({
    int? currentStep,
    String? companyName,
    String? document,
    WorkType? workType,
    Map<SectionKey, SectionState>? sections,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      companyName: companyName ?? this.companyName,
      document: document ?? this.document,
      workType: workType ?? this.workType,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    companyName,
    document,
    workType,
    sections,
  ];
}
