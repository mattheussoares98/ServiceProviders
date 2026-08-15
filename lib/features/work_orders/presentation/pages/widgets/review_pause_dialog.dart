import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ReviewPauseDialog extends HookWidget {
  const ReviewPauseDialog({
    required this.pauseRequest,
    required this.currentUserId,
    super.key,
  });

  final PauseRequestEntity pauseRequest;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(() => GetIt.I<PauseWorkflowCubit>());
    final notesController = useTextEditingController();
    //TODO check this dialog
    final selectedResponsibility = useState<PauseResponsibility>(
      pauseRequest.responsibility ?? PauseResponsibility.provider,
    );

    final dropdownResponsibilities = PauseResponsibility.values.map((resp) {
      return DropdownMenuItem<PauseResponsibility>(
        value: resp,
        child: BaseText.bodyMedium(resp.label),
      );
    }).toList();

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
                    'Revisar solicitação de pausa'.hardcoded,
                    fontWeight: FontWeight.bold,
                  ),
                  gapH16,
                  BaseTextFormField(
                    controller: notesController,
                    labelText: 'Observação do revisor (opcional)'.hardcoded,
                    hintText:
                        'Digite o motivo da aprovação ou rejeição'.hardcoded,
                    maxLength: 250,
                    maxLines: 3,
                  ),
                  gapH12,
                  BaseDropDown<PauseResponsibility>(
                    label: 'Responsabilidade'.hardcoded,
                    items: dropdownResponsibilities,
                    selectedItem: selectedResponsibility.value,
                    onChanged: (val) {
                      selectedResponsibility.value = val;
                    },
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
                            id: pauseRequest.id,
                            status: PauseRequestStatus.rejected,
                            reviewedById: currentUserId,
                            workOrderId: pauseRequest.workOrderId,
                            responsibility: selectedResponsibility.value,
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
                      BaseButton(
                        text: 'Aprovar'.hardcoded,
                        onTap: () async {
                          final success = await cubit.reviewPause(
                            id: pauseRequest.id,
                            status: PauseRequestStatus.approved,
                            reviewedById: currentUserId,
                            workOrderId: pauseRequest.workOrderId,
                            responsibility: selectedResponsibility.value,
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
