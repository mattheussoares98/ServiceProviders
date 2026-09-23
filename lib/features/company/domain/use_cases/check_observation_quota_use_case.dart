import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_order_observations_repository.dart';

class CheckObservationQuotaParams extends Equatable {
  const CheckObservationQuotaParams({
    required this.workOrderId,
    this.currentCount,
  });

  final String workOrderId;
  final int? currentCount;

  @override
  List<Object?> get props => [workOrderId, currentCount];
}

@LazySingleton()
class CheckObservationQuotaUseCase
    implements UseCase<bool, CheckObservationQuotaParams> {
  CheckObservationQuotaUseCase({
    required GetActiveCompanyIdUseCase getActiveCompanyIdUseCase,
    required GetCompanyParametersUseCase getCompanyParametersUseCase,
    required WorkOrderObservationsRepository observationsRepository,
  }) : _getActiveCompanyIdUseCase = getActiveCompanyIdUseCase,
       _getCompanyParametersUseCase = getCompanyParametersUseCase,
       _observationsRepository = observationsRepository;

  final GetActiveCompanyIdUseCase _getActiveCompanyIdUseCase;
  final GetCompanyParametersUseCase _getCompanyParametersUseCase;
  final WorkOrderObservationsRepository _observationsRepository;

  @override
  FutureBool call(CheckObservationQuotaParams request) async {
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
    if (parameters.maxObservationsPerWorkOrder == 0) {
      return const SuccessState(data: true);
    }

    int count = request.currentCount ?? 0;
    if (request.currentCount == null) {
      final observationsResult = await _observationsRepository.getObservations(
        request.workOrderId,
      );
      if (observationsResult is! SuccessState ||
          observationsResult.data == null) {
        return FailureState<bool>(
          message: observationsResult.message,
          error: observationsResult.error,
          statusCode: observationsResult.statusCode,
        );
      }
      count = observationsResult.data!.length;
    }

    final canAdd = parameters.canAddObservation(count);
    return SuccessState(data: canAdd);
  }
}
