import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/create_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/delete_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/update_sector_use_case.dart';

@LazySingleton()
class SectorsCubitUseCases {
  SectorsCubitUseCases({
    required this.getSectors,
    required this.createSector,
    required this.updateSector,
    required this.deleteSector,
    required this.getActiveCompanyId,
  });

  final GetSectorsUseCase getSectors;
  final CreateSectorUseCase createSector;
  final UpdateSectorUseCase updateSector;
  final DeleteSectorUseCase deleteSector;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
}

