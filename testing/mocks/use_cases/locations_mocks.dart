import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_address_by_cep_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/watch_areas_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/watch_locations_realtime_use_case.dart';

class MockWatchLocationsRealtimeUseCase extends Mock
    implements WatchLocationsRealtimeUseCase {}

class MockWatchAreasRealtimeUseCase extends Mock
    implements WatchAreasRealtimeUseCase {}

class MockGetAddressByCepUseCase extends Mock
    implements GetAddressByCepUseCase {}
