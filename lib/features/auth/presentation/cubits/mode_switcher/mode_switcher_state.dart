part of 'mode_switcher_cubit.dart';

class ModeSwitcherState extends BaseState {
  const ModeSwitcherState({
    super.status = DataStatus.initial,
    this.selectedMode,
    this.canSwitchMode = false,
    super.errorMessage,
    super.sections = const {},
  });

  final AppMode? selectedMode;
  final bool canSwitchMode;

  ModeSwitcherState copyWith({
    DataStatus? status,
    AppMode? selectedMode,
    bool? canSwitchMode,
    String? errorMessage,
    bool? annulSelectedMode,
    bool? annulErrorMessage,
    Map<SectionKey, SectionStatus>? sections,
  }) {
    return ModeSwitcherState(
      sections: sections ?? this.sections,
      status: status ?? this.status,
      selectedMode: annulSelectedMode == true
          ? null
          : selectedMode ?? this.selectedMode,
      canSwitchMode: canSwitchMode ?? this.canSwitchMode,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedMode,
    canSwitchMode,
    errorMessage,
    sections,
  ];
}
