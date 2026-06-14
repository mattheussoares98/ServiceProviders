part of 'configurations_cubit.dart';

class ConfigurationsState extends BaseState {
  const ConfigurationsState({
    required this.configurations,
    super.status = StateStatus.initial,
    this.errorMessage = '',
  });

  const ConfigurationsState.initial()
      : configurations = const ConfigurationsEntity(
          pushNotificationsEnabled: true,
          themeMode: 'system',
        ),
        errorMessage = '',
        super(status: StateStatus.initial);

  final ConfigurationsEntity configurations;
  final String errorMessage;

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
