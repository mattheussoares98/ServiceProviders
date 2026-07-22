import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ReviewPauseDialog extends HookWidget {
  const ReviewPauseDialog({
    required this.pauseRequestId,
    required this.workOrderId,
    required this.currentUserId,
    super.key,
  });

  final String pauseRequestId;
  final String workOrderId;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(() => GetIt.I<PauseWorkflowCubit>());
    final notesController = useTextEditingController();
    //TODO check this dialog
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
                    'Revisar Solicitação de Pausa'.hardcoded,
                    fontWeight: FontWeight.bold,
                  ),
                  gapH16,
                  BaseTextFormField(
                    controller: notesController,
                    labelText: 'Observação do Revisor (opcional)'.hardcoded,
                    hintText:
                        'Digite o motivo da aprovação ou rejeição'.hardcoded,
                    maxLength: 250,
                    maxLines: 3,
                  ),
                  gapH24,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SecondaryButton(
                        text: 'Cancelar'.hardcoded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      gapW8,
                      SecondaryButton(
                        text: 'Rejeitar'.hardcoded,
                        onTap: () async {
                          final success = await cubit.reviewPause(
                            id: pauseRequestId,
                            status: PauseRequestStatus.rejected,
                            reviewedById: currentUserId,
                            workOrderId: workOrderId,
                            reviewObservation:
                                notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                          );
                          if (success && context.mounted) {
                            Navigator.of(context).pop(false);
                          }
                        },
                      ),
                      gapW8,
                      PrimaryButton(
                        text: 'Aprovar'.hardcoded,
                        onTap: () async {
                          final success = await cubit.reviewPause(
                            id: pauseRequestId,
                            status: PauseRequestStatus.approved,
                            reviewedById: currentUserId,
                            workOrderId: workOrderId,
                            reviewObservation:
                                notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
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
