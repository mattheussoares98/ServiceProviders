part of 'mode_switcher_cubit.dart';

class ModeSwitcherState extends BaseState {
  const ModeSwitcherState({
    super.status = StateStatus.initial,
    this.selectedMode,
    this.canSwitchMode = false,
    super.errorMessage,
    super.sections = const {},
  });

  final AppMode? selectedMode;
  final bool canSwitchMode;

  ModeSwitcherState copyWith({
    StateStatus? status,
    AppMode? selectedMode,
    bool? canSwitchMode,
    String? errorMessage,
    bool? annulSelectedMode,
    bool? annulErrorMessage,
  }) {
    return ModeSwitcherState(
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
  ];
}
