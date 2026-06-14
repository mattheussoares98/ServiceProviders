import 'package:equatable/equatable.dart';

class ConfigurationsEntity extends Equatable {
  const ConfigurationsEntity({
    required this.pushNotificationsEnabled,
    required this.themeMode,
  });

  final bool pushNotificationsEnabled;
  final String themeMode;

  ConfigurationsEntity copyWith({
    bool? pushNotificationsEnabled,
    String? themeMode,
  }) {
    return ConfigurationsEntity(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [pushNotificationsEnabled, themeMode];
}
