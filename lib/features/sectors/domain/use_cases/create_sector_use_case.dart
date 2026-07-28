import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/repositories/sectors_repository.dart';

@LazySingleton()
class CreateSectorUseCase implements UseCase<bool, SectorEntity> {
  CreateSectorUseCase({required SectorsRepository sectorsRepository})
      : _sectorsRepository = sectorsRepository;

  final SectorsRepository _sectorsRepository;

  @override
  FutureBool call(SectorEntity request) =>
      _sectorsRepository.createSector(request);
}
