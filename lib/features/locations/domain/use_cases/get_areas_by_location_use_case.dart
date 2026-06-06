import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/repositories/locations_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetAreasByLocationUseCase implements UseCase<List<AreaEntity>, String> {
  GetAreasByLocationUseCase({required LocationsRepository locationsRepository})
      : _locationsRepository = locationsRepository;

  final LocationsRepository _locationsRepository;

  @override
  FutureList<AreaEntity> call(String request) =>
      _locationsRepository.getAreasByLocation(request);
}
