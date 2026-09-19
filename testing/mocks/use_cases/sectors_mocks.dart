import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/create_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/delete_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/update_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/watch_sectors_realtime_use_case.dart';

class MockGetSectorsUseCase extends Mock implements GetSectorsUseCase {}

class MockCreateSectorUseCase extends Mock implements CreateSectorUseCase {}

class MockUpdateSectorUseCase extends Mock implements UpdateSectorUseCase {}

class MockDeleteSectorUseCase extends Mock implements DeleteSectorUseCase {}

class MockWatchSectorsRealtimeUseCase extends Mock
    implements WatchSectorsRealtimeUseCase {}
