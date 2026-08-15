import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/title_and_subtitle.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class ReviewCompletionDialog extends HookWidget {
  const ReviewCompletionDialog({
    required this.pauseRequest,
    required this.currentUserId,
    super.key,
  });
  final PauseRequestEntity pauseRequest;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(() => GetIt.I<PauseWorkflowCubit>());
    final observationController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    Future<void> reviewCompletion(bool accept) async {
      if (!accept && formKey.currentState?.validate() != true) {
        return;
      }

      final success = await cubit.reviewCompletion(
        id: pauseRequest.id,
        status: accept
            ? PauseRequestStatus.approved
            : PauseRequestStatus.rejected,
        reviewedById: currentUserId,
        workOrderId: pauseRequest.workOrderId,
        reviewObservation: observationController.text.trim(),
        completionReason: pauseRequest.customReason,
        completionSectorId: pauseRequest.sectorId,
      );

      if (success && context.mounted) {
        Navigator.of(context).pop(accept);
      }
    }

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<PauseWorkflowCubit, PauseWorkflowState>(
        builder: (context, state) {
          final isSaving = state.status == StateStatus.saving;
          return IgnorePointer(
            ignoring: isSaving,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.p16),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Sizes.p24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BaseText.titleMedium(
                        'Revisar solicitação de conclusão'.hardcoded,
                        fontWeight: FontWeight.bold,
                      ),
                      gapH16,
                      if (pauseRequest.customReason?.isNotEmpty ?? false) ...[
                        TitleAndSubtitle(
                          title: 'Justificativa'.hardcoded,
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
                      BaseTextFormField(
                        enabled: !isSaving,
                        controller: observationController,
                        labelText: 'Observação do revisor'.hardcoded,
                        hintText:
                            'Motivo de rejeição ou nota de aprovação'.hardcoded,
                        maxLength: 250,
                        maxLines: 10,
                        validator: FormValidators.compose([
                          NonEmptyValidator(),
                          MinLengthValidator(5),
                        ]),
                      ),
                      gapH24,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: SecondaryButton(
                              text: 'Rejeitar'.hardcoded,
                              isLoading: isSaving,
                              onTap: () => reviewCompletion(false),
                              color: Colors.red,
                            ),
                          ),
                          gapW12,
                          Flexible(
                            child: BaseButton(
                              text: 'Aprovar'.hardcoded,
                              isLoading: isSaving,
                              onTap: () => reviewCompletion(true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
