import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/create_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';

@LazySingleton()
class SectorsCubitUseCases {
  SectorsCubitUseCases({
    required this.getSectors,
    required this.createSector,
  });

  final GetSectorsUseCase getSectors;
  final CreateSectorUseCase createSector;
}
