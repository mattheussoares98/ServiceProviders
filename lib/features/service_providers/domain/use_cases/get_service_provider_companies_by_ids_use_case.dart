import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/repositories/service_provider_repository.dart';

/// Loads the provider companies the signed-in user belongs to, for the provider
/// mode company filter. Unlike `GetServiceProviderCompaniesUseCase` this is not
/// scoped to a single contracting company.
@LazySingleton()
class GetServiceProviderCompaniesByIdsUseCase
    implements UseCase<List<ServiceProviderCompanyEntity>, List<String>> {
  GetServiceProviderCompaniesByIdsUseCase({
    required ServiceProviderRepository serviceProviderRepository,
  }) : _serviceProviderRepository = serviceProviderRepository;

  final ServiceProviderRepository _serviceProviderRepository;

  @override
  FutureList<ServiceProviderCompanyEntity> call(List<String> ids) =>
      _serviceProviderRepository.getServiceProviderCompaniesByIds(ids);
}
