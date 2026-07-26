import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/repositories/service_provider_repository.dart';

class SendServiceProviderInvitationParams extends Equatable {
  const SendServiceProviderInvitationParams({
    required this.serviceProviderCompanyId,
    required this.email,
  });

  final String serviceProviderCompanyId;
  final String email;

  @override
  List<Object?> get props => [serviceProviderCompanyId, email];
}

@LazySingleton()
class SendServiceProviderInvitationUseCase
    implements UseCase<bool, SendServiceProviderInvitationParams> {
  SendServiceProviderInvitationUseCase({
    required ServiceProviderRepository serviceProviderRepository,
  }) : _serviceProviderRepository = serviceProviderRepository;

  final ServiceProviderRepository _serviceProviderRepository;

  @override
  FutureBool call(SendServiceProviderInvitationParams params) =>
      _serviceProviderRepository.sendServiceProviderInvitation(
        serviceProviderCompanyId: params.serviceProviderCompanyId,
        email: params.email,
      );
}
