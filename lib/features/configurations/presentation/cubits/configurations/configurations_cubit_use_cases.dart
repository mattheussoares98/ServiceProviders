import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/get_configurations_use_case.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/use_cases/save_configurations_use_case.dart';

@LazySingleton()
class ConfigurationsCubitUseCases {
  const ConfigurationsCubitUseCases({
    required this.getConfigurations,
    required this.saveConfigurations,
  });

  final GetConfigurationsUseCase getConfigurations;
  final SaveConfigurationsUseCase saveConfigurations;
}
