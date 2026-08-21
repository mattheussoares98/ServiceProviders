import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/repositories/locations_repository.dart';

@LazySingleton()
class GetAreasByIdsUseCase implements UseCase<List<AreaEntity>, List<String>> {
  GetAreasByIdsUseCase({required LocationsRepository locationsRepository})
    : _locationsRepository = locationsRepository;

  final LocationsRepository _locationsRepository;

  @override
  FutureList<AreaEntity> call(List<String> request) =>
      _locationsRepository.getAreasByIds(request);
}
