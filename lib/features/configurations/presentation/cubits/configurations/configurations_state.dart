part of 'configurations_cubit.dart';

class ConfigurationsState extends BaseState {
  const ConfigurationsState({
    required this.configurations,
    super.sections = const {},
  });

  const ConfigurationsState.initial()
    : configurations = const ConfigurationsEntity(
        pushNotificationsEnabled: true,
        themeMode: 'system',
        systemNotificationsEnabled: true,
      ),
      super(sections: const {});

  final ConfigurationsEntity configurations;

  ThemeMode get themeMode {
    return ThemeMode.values.firstWhere(
      (e) => e.name == configurations.themeMode,
      orElse: () => ThemeMode.system,
    );
  }

  ConfigurationsState copyWith({
    ConfigurationsEntity? configurations,
    Map<SectionKey, SectionState>? sections,
  }) {
    return ConfigurationsState(
      configurations: configurations ?? this.configurations,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [configurations, sections];
}
