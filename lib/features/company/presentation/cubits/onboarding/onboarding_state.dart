part of 'onboarding_cubit.dart';

final class OnboardingState extends BaseState {
  const OnboardingState({
    this.currentStep = 0,
    this.companyName = '',
    String? document,
    String? cnpj,
    this.workType = WorkType.internalOnly,
    super.sections,
  }) : document = document ?? cnpj ?? '';

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

  @Deprecated('Use document instead')
  String get cnpj => document;

  OnboardingState copyWith({
    int? currentStep,
    String? companyName,
    String? document,
    String? cnpj,
    WorkType? workType,
    Map<SectionKey, SectionState>? sections,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      companyName: companyName ?? this.companyName,
      document: document ?? cnpj ?? this.document,
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
