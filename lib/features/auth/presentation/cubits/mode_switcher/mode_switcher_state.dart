part of 'mode_switcher_cubit.dart';

class ModeSwitcherState extends Equatable {
  const ModeSwitcherState({
    this.status = StateStatus.initial,
    this.selectedMode,
    this.canSwitchMode = false,
    this.errorMessage,
  });

  final StateStatus status;
  final AppMode? selectedMode;
  final bool canSwitchMode;
  final String? errorMessage;

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
  List<Object?> get props => [status, selectedMode, canSwitchMode, errorMessage];
}
