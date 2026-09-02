part of 'mode_switcher_cubit.dart';

class ModeSwitcherState extends BaseState {
  const ModeSwitcherState({
    this.selectedMode,
    this.canSwitchMode = false,
    super.sections = const {},
  });

  final AppMode? selectedMode;
  final bool canSwitchMode;

  ModeSwitcherState copyWith({
    AppMode? selectedMode,
    bool? canSwitchMode,
    bool? annulSelectedMode,
    Map<SectionKey, SectionState>? sections,
  }) {
    return ModeSwitcherState(
      sections: sections ?? this.sections,
      selectedMode: annulSelectedMode == true
          ? null
          : selectedMode ?? this.selectedMode,
      canSwitchMode: canSwitchMode ?? this.canSwitchMode,
    );
  }

  @override
  List<Object?> get props => [selectedMode, canSwitchMode, sections];
}
