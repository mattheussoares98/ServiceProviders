import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/address_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/repositories/locations_repository.dart';

@LazySingleton()
class GetAddressByCepUseCase implements UseCase<AddressEntity, String> {
  GetAddressByCepUseCase({required LocationsRepository locationsRepository})
    : _locationsRepository = locationsRepository;

  final LocationsRepository _locationsRepository;

  @override
  FutureData<AddressEntity> call(String request) =>
      _locationsRepository.getAddressByCep(request);
}
