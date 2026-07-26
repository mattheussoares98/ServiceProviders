import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ReviewCompletionDialog extends HookWidget {
  const ReviewCompletionDialog({
    required this.pauseRequest,
    required this.currentUserId,
    super.key,
  });
  //TODO check this entire code
  final PauseRequestEntity pauseRequest;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(() => GetIt.I<PauseWorkflowCubit>());
    final observationController = useTextEditingController();

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<PauseWorkflowCubit, PauseWorkflowState>(
        builder: (context, state) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.p16),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Sizes.p24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BaseText.titleMedium(
                    'Revisar Solicitação de Conclusão'.hardcoded,
                    fontWeight: FontWeight.bold,
                  ),
                  gapH16,
                  if (pauseRequest.customReason != null) ...[
                    BaseText.bodySmall(
                      'Justificativa:'.hardcoded,
                      color: Colors.grey[700],
                    ),
                    BaseText.bodyMedium(pauseRequest.customReason!),
                    gapH12,
                  ],
                  if (pauseRequest.observation != null) ...[
                    BaseText.bodySmall(
                      'Observação:'.hardcoded,
                      color: Colors.grey[700],
                    ),
                    BaseText.bodyMedium(pauseRequest.observation!),
                    gapH12,
                  ],
                  BaseTextFormField(
                    controller: observationController,
                    labelText: 'Observação do Revisor'.hardcoded,
                    hintText:
                        'Motivo de rejeição ou nota de aprovação'.hardcoded,
                    maxLength: 250,
                    maxLines: 2,
                  ),
                  gapH24,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SecondaryButton(
                        text: 'Rejeitar'.hardcoded,
                        onTap: () async {
                          if (observationController.text.trim().isEmpty) {
                            cubit.showErrorToast(
                              'Por favor, informe o motivo da rejeição.'
                                  .hardcoded,
                            );
                            return;
                          }

                          final success = await cubit.reviewCompletion(
                            id: pauseRequest.id,
                            status: PauseRequestStatus.rejected,
                            reviewedById: currentUserId,
                            workOrderId: pauseRequest.workOrderId,
                            reviewObservation: observationController.text
                                .trim(),
                          );

                          if (success && context.mounted) {
                            Navigator.of(context).pop(false);
                          }
                        },
                      ),
                      BaseButton(
                        text: 'Aprovar'.hardcoded,
                        onTap: () async {
                          final success = await cubit.reviewCompletion(
                            id: pauseRequest.id,
                            status: PauseRequestStatus.approved,
                            reviewedById: currentUserId,
                            workOrderId: pauseRequest.workOrderId,
                            reviewObservation:
                                observationController.text.trim().isEmpty
                                ? null
                                : observationController.text.trim(),
                          );

                          if (success && context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
