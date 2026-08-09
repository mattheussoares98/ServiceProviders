import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/repositories/configurations_repository.dart';

@LazySingleton()
class ClearAppCacheUseCase implements UseCaseNoParameter<void> {
  ClearAppCacheUseCase({
    required ConfigurationsRepository configurationsRepository,
  }) : _configurationsRepository = configurationsRepository;

  final ConfigurationsRepository _configurationsRepository;

  @override
  FutureVoid call() => _configurationsRepository.clearAppCache();
}
