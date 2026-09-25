part of 'onboarding_cubit.dart';

final class OnboardingState extends BaseState {
  const OnboardingState({
    this.currentStep = 0,
    this.companyName = '',
    this.cnpj = '',
    this.workType = WorkType.internalOnly,
    super.sections,
  });

  const OnboardingState.initial()
    : currentStep = 0,
      companyName = '',
      cnpj = '',
      workType = WorkType.internalOnly,
      super();

  final int currentStep;
  final String companyName;
  final String cnpj;
  final WorkType workType;

  OnboardingState copyWith({
    int? currentStep,
    String? companyName,
    String? cnpj,
    WorkType? workType,
    Map<SectionKey, SectionState>? sections,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      companyName: companyName ?? this.companyName,
      cnpj: cnpj ?? this.cnpj,
      workType: workType ?? this.workType,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    companyName,
    cnpj,
    workType,
    sections,
  ];
}
