import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/repositories/locations_repository.dart';

/// Every area of a contracting company, read from provider mode. Never cached
/// locally — see [LocationsRepository.getProviderAreas].
@LazySingleton()
class GetProviderAreasUseCase implements UseCase<List<AreaEntity>, String> {
  GetProviderAreasUseCase({required LocationsRepository locationsRepository})
    : _locationsRepository = locationsRepository;

  final LocationsRepository _locationsRepository;

  @override
  FutureList<AreaEntity> call(String request) =>
      _locationsRepository.getProviderAreas(request);
}
