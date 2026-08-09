import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/clear_app_cache_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/get_configurations_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/save_configurations_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/save_theme_mode_use_case.dart';

@LazySingleton()
class ConfigurationsCubitUseCases {
  const ConfigurationsCubitUseCases({
    required this.getConfigurations,
    required this.saveConfigurations,
    required this.saveThemeMode,
    required this.clearAppCache,
  });

  final GetConfigurationsUseCase getConfigurations;
  final SaveConfigurationsUseCase saveConfigurations;
  final SaveThemeModeUseCase saveThemeMode;
  final ClearAppCacheUseCase clearAppCache;
}
