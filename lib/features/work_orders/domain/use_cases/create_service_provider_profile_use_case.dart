import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/service_provider_repository.dart';

@LazySingleton()
class CreateServiceProviderProfileUseCase
    implements UseCase<bool, ServiceProviderProfileEntity> {
  CreateServiceProviderProfileUseCase({
    required ServiceProviderRepository serviceProviderRepository,
  }) : _serviceProviderRepository = serviceProviderRepository;

  final ServiceProviderRepository _serviceProviderRepository;

  @override
  FutureBool call(ServiceProviderProfileEntity profile) =>
      _serviceProviderRepository.createServiceProviderProfile(profile);
}
