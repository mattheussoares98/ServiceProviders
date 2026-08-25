import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/repositories/locations_repository.dart';

@LazySingleton()
class WatchAreasRealtimeUseCase {
  const WatchAreasRealtimeUseCase({
    required LocationsRepository locationsRepository,
  }) : _locationsRepository = locationsRepository;

  final LocationsRepository _locationsRepository;

  Stream<RealtimeEvent<AreaEntity>> call({String? companyId}) =>
      _locationsRepository.watchAreasRealtime(companyId: companyId);
}
