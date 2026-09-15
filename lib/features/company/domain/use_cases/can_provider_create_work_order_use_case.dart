import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/repositories/company_repository.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';

class CanProviderCreateWorkOrderParams extends Equatable {
  const CanProviderCreateWorkOrderParams({
    required this.companies,
    this.selectedCompanyId,
  });

  final List<ServiceProviderCompanyEntity> companies;
  final String? selectedCompanyId;

  @override
  List<Object?> get props => [companies, selectedCompanyId];
}

@LazySingleton()
class CanProviderCreateWorkOrderUseCase
    implements UseCase<bool, CanProviderCreateWorkOrderParams> {
  const CanProviderCreateWorkOrderUseCase({
    required CompanyRepository companyRepository,
  }) : _companyRepository = companyRepository;

  final CompanyRepository _companyRepository;

  @override
  FutureBool call(CanProviderCreateWorkOrderParams params) async {
    if (params.companies.isEmpty) {
      return const SuccessState(data: false);
    }

    if (params.selectedCompanyId != null) {
      final selected = params.companies.firstWhereOrNull(
        (c) => c.id == params.selectedCompanyId,
      );
      if (selected == null) {
        return const SuccessState(data: false);
      }
      final paramsResult = await _companyRepository.getCompanyParameters(
        selected.companyId,
      );
      if (paramsResult is SuccessState<CompanyParameterEntity>) {
        return SuccessState(
          data: paramsResult.data?.allowProviderCreateWorkOrder ?? false,
        );
      }
      return const SuccessState(data: false);
    }

    if (params.companies.length == 1) {
      final paramsResult = await _companyRepository.getCompanyParameters(
        params.companies.first.companyId,
      );
      if (paramsResult is SuccessState<CompanyParameterEntity>) {
        return SuccessState(
          data: paramsResult.data?.allowProviderCreateWorkOrder ?? false,
        );
      }
      return const SuccessState(data: false);
    }

    for (final company in params.companies) {
      final paramsResult = await _companyRepository.getCompanyParameters(
        company.companyId,
      );
      if (paramsResult is SuccessState<CompanyParameterEntity> &&
          paramsResult.data?.allowProviderCreateWorkOrder == true) {
        return const SuccessState(data: true);
      }
    }

    return const SuccessState(data: false);
  }
}
