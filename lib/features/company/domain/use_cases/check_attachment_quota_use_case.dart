import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_parameters_use_case.dart';

class CheckAttachmentQuotaParams extends Equatable {
  const CheckAttachmentQuotaParams({
    required this.workOrderId,
    this.currentCount,
  });

  final String workOrderId;
  final int? currentCount;

  @override
  List<Object?> get props => [workOrderId, currentCount];
}

@LazySingleton()
class CheckAttachmentQuotaUseCase
    implements UseCase<bool, CheckAttachmentQuotaParams> {
  CheckAttachmentQuotaUseCase({
    required GetActiveCompanyIdUseCase getActiveCompanyIdUseCase,
    required GetCompanyParametersUseCase getCompanyParametersUseCase,
    required AttachmentsRepository attachmentsRepository,
  }) : _getActiveCompanyIdUseCase = getActiveCompanyIdUseCase,
       _getCompanyParametersUseCase = getCompanyParametersUseCase,
       _attachmentsRepository = attachmentsRepository;

  final GetActiveCompanyIdUseCase _getActiveCompanyIdUseCase;
  final GetCompanyParametersUseCase _getCompanyParametersUseCase;
  final AttachmentsRepository _attachmentsRepository;

  @override
  FutureBool call(CheckAttachmentQuotaParams request) async {
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
    if (parameters.maxAttachmentsPerWorkOrder == 0) {
      return const SuccessState(data: true);
    }

    int count = request.currentCount ?? 0;
    if (request.currentCount == null) {
      final attachmentsResult = await _attachmentsRepository
          .getAttachmentsByWorkOrder(request.workOrderId);
      if (attachmentsResult is! SuccessState ||
          attachmentsResult.data == null) {
        return FailureState<bool>(
          message: attachmentsResult.message,
          error: attachmentsResult.error,
          statusCode: attachmentsResult.statusCode,
        );
      }
      count = attachmentsResult.data!.length;
    }

    final canAdd = parameters.canAddAttachment(count);
    return SuccessState(data: canAdd);
  }
}
