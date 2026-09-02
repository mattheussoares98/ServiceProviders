import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
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
          final isSaving =
              state.sections[PauseWorkflowSections.reviewPause] ==
              const SectionState.running();
          return IgnorePointer(
            ignoring: isSaving,
            child: Dialog(
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
                      'Definir responsabilidade da pausa'.hardcoded,
                      fontWeight: FontWeight.bold,
                    ),
                    gapH16,
                    if (pauseRequest.customReason?.isNotEmpty ?? false) ...[
                      TitleAndSubtitle(
                        title: 'Motivo'.hardcoded,
                        subtitle: pauseRequest.customReason,
                      ),
                      gapH12,
                    ],
                    if (pauseRequest.observation?.isNotEmpty ?? false) ...[
                      TitleAndSubtitle(
                        title: 'Observação'.hardcoded,
                        subtitle: pauseRequest.observation,
                      ),
                      gapH12,
                    ],
                    BaseDropDown<PauseResponsibility>(
                      label: 'Responsabilidade'.hardcoded,
                      showLabelAtTopLeft: true,
                      items: dropdownResponsibilities,
                      selectedItem: selectedResponsibility.value,
                      onChanged: isSaving
                          ? null
                          : (val) {
                              selectedResponsibility.value = val;
                            },
                    ),
                    gapH12,
                    BaseTextFormField(
                      enabled: !isSaving,
                      controller: notesController,
                      labelText: 'Observação do revisor (opcional)'.hardcoded,
                      hintText:
                          'Digite uma observação sobre esta pausa'.hardcoded,
                      maxLength: 250,
                      maxLines: 3,
                    ),
                    gapH24,
                    BaseButton(
                      text: 'Salvar'.hardcoded,
                      isLoading: isSaving,
                      onTap: () async {
                        final success = await cubit.reviewPause(
                          id: pauseRequest.id,
                          status: PauseRequestStatus.approved,
                          reviewedById: currentUserId,
                          workOrderId: pauseRequest.workOrderId,
                          responsibility: selectedResponsibility.value,
                          reviewObservation: notesController.text.trim().isEmpty
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
              ),
            ),
          );
        },
      ),
    );
  }
}
