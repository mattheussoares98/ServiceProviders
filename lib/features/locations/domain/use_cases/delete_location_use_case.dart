import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/locations/domain/repositories/locations_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class DeleteLocationUseCase implements UseCase<bool, String> {
  DeleteLocationUseCase({required LocationsRepository locationsRepository})
      : _locationsRepository = locationsRepository;

  final LocationsRepository _locationsRepository;

  @override
  FutureBool call(String request) =>
      _locationsRepository.deleteLocation(request);
}
