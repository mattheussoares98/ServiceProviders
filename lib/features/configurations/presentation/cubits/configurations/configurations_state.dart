part of 'configurations_cubit.dart';

class ConfigurationsState extends BaseState {
  const ConfigurationsState({
    required this.configurations,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const ConfigurationsState.initial()
      : configurations = const ConfigurationsEntity(
          pushNotificationsEnabled: true,
          themeMode: 'system',
        ),
        super(status: StateStatus.initial, errorMessage: '');

  final ConfigurationsEntity configurations;

  ThemeMode get themeMode {
    return ThemeMode.values.firstWhere(
      (e) => e.name == configurations.themeMode,
      orElse: () => ThemeMode.system,
    );
  }

  ConfigurationsState copyWith({
    ConfigurationsEntity? configurations,
    StateStatus? status,
    String? errorMessage,
  }) {
    return ConfigurationsState(
      configurations: configurations ?? this.configurations,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [configurations, status, errorMessage];
}
