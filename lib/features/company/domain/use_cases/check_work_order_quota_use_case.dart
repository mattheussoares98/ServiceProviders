import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

@LazySingleton()
class CheckWorkOrderQuotaUseCase implements UseCaseNoParameter<bool> {
  CheckWorkOrderQuotaUseCase({
    required GetActiveCompanyIdUseCase getActiveCompanyIdUseCase,
    required GetCompanyParametersUseCase getCompanyParametersUseCase,
    required WorkOrdersRepository workOrdersRepository,
  }) : _getActiveCompanyIdUseCase = getActiveCompanyIdUseCase,
       _getCompanyParametersUseCase = getCompanyParametersUseCase,
       _workOrdersRepository = workOrdersRepository;

  final GetActiveCompanyIdUseCase _getActiveCompanyIdUseCase;
  final GetCompanyParametersUseCase _getCompanyParametersUseCase;
  final WorkOrdersRepository _workOrdersRepository;

  @override
  FutureBool call() async {
    final companyId = _getActiveCompanyIdUseCase();

    final paramsResult = await _getCompanyParametersUseCase(companyId);
    if (paramsResult is! SuccessState || paramsResult.data == null) {
      return FailureState<bool>(
        message: paramsResult.message,
        error: paramsResult.error,
        statusCode: paramsResult.statusCode,
      );
    }

    final parameters = paramsResult.data!;
    if (parameters.hasUnlimitedDailyWorkOrders) {
      return const SuccessState(data: true);
    }

    final countResult = await _workOrdersRepository.countTodayWorkOrders(
      companyId,
    );
    if (countResult is! SuccessState || countResult.data == null) {
      return FailureState<bool>(
        message: countResult.message,
        error: countResult.error,
        statusCode: countResult.statusCode,
      );
    }

    final todayCount = countResult.data!;
    final canCreate = parameters.canCreateWorkOrder(todayCount);
    return SuccessState(data: canCreate);
  }
}
