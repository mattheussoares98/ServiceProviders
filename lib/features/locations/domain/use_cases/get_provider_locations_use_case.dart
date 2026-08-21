import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/repositories/locations_repository.dart';

/// Every location of a contracting company, read from provider mode. Never
/// cached locally — see [LocationsRepository.getProviderLocations].
@LazySingleton()
class GetProviderLocationsUseCase
    implements UseCase<List<LocationEntity>, String> {
  GetProviderLocationsUseCase({
    required LocationsRepository locationsRepository,
  }) : _locationsRepository = locationsRepository;

  final LocationsRepository _locationsRepository;

  @override
  FutureList<LocationEntity> call(String request) =>
      _locationsRepository.getProviderLocations(request);
}
