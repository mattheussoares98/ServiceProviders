import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/repositories/service_provider_repository.dart';

@LazySingleton()
class WatchServiceProviderProfilesRealtimeUseCase {
  const WatchServiceProviderProfilesRealtimeUseCase({
    required ServiceProviderRepository serviceProviderRepository,
  }) : _serviceProviderRepository = serviceProviderRepository;

  final ServiceProviderRepository _serviceProviderRepository;

  Stream<RealtimeEvent<ServiceProviderProfileEntity>> call({
    String? serviceProviderCompanyId,
  }) => _serviceProviderRepository.watchServiceProviderProfilesRealtime(
    serviceProviderCompanyId: serviceProviderCompanyId,
  );
}
