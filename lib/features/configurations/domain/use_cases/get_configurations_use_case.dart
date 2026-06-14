import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/configurations/domain/entities/configurations_entity.dart';
import 'package:clean_architecture/features/configurations/domain/repositories/configurations_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetConfigurationsUseCase
    implements UseCaseNoParameter<ConfigurationsEntity> {
  GetConfigurationsUseCase({
    required ConfigurationsRepository configurationsRepository,
  }) : _configurationsRepository = configurationsRepository;

  final ConfigurationsRepository _configurationsRepository;

  @override
  FutureData<ConfigurationsEntity> call() =>
      _configurationsRepository.getConfigurations();
}
