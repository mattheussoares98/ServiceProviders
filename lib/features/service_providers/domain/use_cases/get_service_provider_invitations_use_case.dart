import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/repositories/service_provider_repository.dart';

@LazySingleton()
class GetServiceProviderInvitationsUseCase
    implements UseCase<List<ServiceProviderInvitationEntity>, String> {
  GetServiceProviderInvitationsUseCase({
    required ServiceProviderRepository serviceProviderRepository,
  }) : _serviceProviderRepository = serviceProviderRepository;

  final ServiceProviderRepository _serviceProviderRepository;

  @override
  FutureList<ServiceProviderInvitationEntity> call(
    String serviceProviderCompanyId,
  ) => _serviceProviderRepository.getServiceProviderInvitations(
    serviceProviderCompanyId,
  );
}
