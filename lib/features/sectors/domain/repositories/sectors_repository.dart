import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';

abstract interface class SectorsRepository {
  FutureList<SectorEntity> getSectors(String companyId);
  FutureBool createSector(SectorEntity sector);
}
