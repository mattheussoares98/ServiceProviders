import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/repositories/service_provider_repository.dart';

@LazySingleton()
class AcceptServiceProviderInvitationUseCase {
  const AcceptServiceProviderInvitationUseCase({
    required ServiceProviderRepository repository,
  }) : _repository = repository;

  final ServiceProviderRepository _repository;

  FutureBool call(String email) =>
      _repository.acceptServiceProviderInvitation(email);
}
