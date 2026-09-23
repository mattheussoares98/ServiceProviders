import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_use_case.dart';

enum CompanyFeature { maintenancePlans, serviceProviders }

@LazySingleton()
class CheckFeatureEnabledUseCase implements UseCase<bool, CompanyFeature> {
  CheckFeatureEnabledUseCase({
    required GetActiveCompanyIdUseCase getActiveCompanyIdUseCase,
    required GetCompanyUseCase getCompanyUseCase,
    required GetCompanyParametersUseCase getCompanyParametersUseCase,
  }) : _getActiveCompanyIdUseCase = getActiveCompanyIdUseCase,
       _getCompanyUseCase = getCompanyUseCase,
       _getCompanyParametersUseCase = getCompanyParametersUseCase;

  final GetActiveCompanyIdUseCase _getActiveCompanyIdUseCase;
  final GetCompanyUseCase _getCompanyUseCase;
  final GetCompanyParametersUseCase _getCompanyParametersUseCase;

  @override
  FutureBool call(CompanyFeature request) async {
    final companyId = _getActiveCompanyIdUseCase();

    final companyResult = await _getCompanyUseCase(companyId);
    if (companyResult is! SuccessState || companyResult.data == null) {
      return FailureState<bool>(
        message: companyResult.message,
        error: companyResult.error,
        statusCode: companyResult.statusCode,
      );
    }

    final paramsResult = await _getCompanyParametersUseCase(companyId);
    if (paramsResult is! SuccessState || paramsResult.data == null) {
      return FailureState<bool>(
        message: paramsResult.message,
        error: paramsResult.error,
        statusCode: paramsResult.statusCode,
      );
    }

    final company = companyResult.data!;
    final parameters = paramsResult.data!;

    final isEnabled = switch (request) {
      CompanyFeature.maintenancePlans => parameters.maintenancePlansEnabled(
        company.planType,
      ),
      CompanyFeature.serviceProviders => parameters.serviceProvidersEnabled(
        company.planType,
      ),
    };

    return SuccessState(data: isEnabled);
  }
}
