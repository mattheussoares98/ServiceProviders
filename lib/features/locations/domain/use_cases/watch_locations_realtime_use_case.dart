import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/repositories/locations_repository.dart';

@LazySingleton()
class WatchLocationsRealtimeUseCase {
  const WatchLocationsRealtimeUseCase({
    required LocationsRepository locationsRepository,
  }) : _locationsRepository = locationsRepository;

  final LocationsRepository _locationsRepository;

  Stream<RealtimeEvent<LocationEntity>> call({String? companyId}) =>
      _locationsRepository.watchLocationsRealtime(companyId: companyId);
}
