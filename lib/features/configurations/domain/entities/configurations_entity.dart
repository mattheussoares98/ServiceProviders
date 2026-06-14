import 'package:equatable/equatable.dart';

class ConfigurationsEntity extends Equatable {
  const ConfigurationsEntity({
    required this.pushNotificationsEnabled,
    required this.themeMode,
    this.systemNotificationsEnabled = true,
  });

  final bool pushNotificationsEnabled;
  final String themeMode;
  final bool systemNotificationsEnabled;

  ConfigurationsEntity copyWith({
    bool? pushNotificationsEnabled,
    String? themeMode,
    bool? systemNotificationsEnabled,
  }) {
    return ConfigurationsEntity(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      systemNotificationsEnabled:
          systemNotificationsEnabled ?? this.systemNotificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        pushNotificationsEnabled,
        themeMode,
        systemNotificationsEnabled,
      ];
}
