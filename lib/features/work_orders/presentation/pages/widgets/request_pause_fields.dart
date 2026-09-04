import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class RequestPauseFields extends HookWidget {
  const RequestPauseFields({required this.workOrderId, super.key});

  final String workOrderId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PauseWorkflowCubit>();
    final canApprovePause = context.hasPermission(
      const ActionPermission.workOrderSubAction(
        WorkOrderSubAction.managePendingRequests,
      ),
    );

    final selectedReason = useState<PauseReasonEntity?>(null);
    final selectedResponsibility = useState<PauseResponsibility>(
      PauseResponsibility.provider,
    );
    final selectedSectorId = useState<String?>(null);
    final customReasonController = useTextEditingController();
    final observationController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final dropdownResponsibilities = PauseResponsibility.values.map((resp) {
      return DropdownMenuItem<PauseResponsibility>(
        value: resp,
        child: BaseText.bodyMedium(resp.label),
      );
    }).toList();

    return BlocProvider.value(
      value: cubit,
      child: BaseScaffold(
        body: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BaseText.titleMedium(
                (canApprovePause ? 'Pausar' : 'Solicitar pausa').hardcoded,
                fontWeight: FontWeight.bold,
              ),
              gapH16,
              BaseStateView<
                PauseWorkflowCubit,
                PauseWorkflowState,
                List<PauseReasonEntity>
              >(
                onRetry: () => cubit.loadPauseReasons(true),
                dataSelector: (state) => state.pauseReasons,
                builder: (context, pauseReasons) {
                  final dropdownReasons = pauseReasons.map((reason) {
                    return DropdownMenuItem<PauseReasonEntity>(
                      value: reason,
                      child: BaseText.bodyMedium(reason.name),
                    );
                  }).toList();

                  return BaseDropDown<PauseReasonEntity>(
                    label: 'Motivo da pausa'.hardcoded,
                    showLabelAtTopLeft: true,
                    hint: BaseText.bodyMedium('Selecione um motivo'.hardcoded),
                    items: dropdownReasons,
                    selectedItem: selectedReason.value,
                    onClear: () => selectedReason.value = null,
                    onChanged: (val) => selectedReason.value = val,
                    validator: (value) =>
                        value == null ? 'Selecione um motivo'.hardcoded : null,
                  );
                },
              ),
              gapH12,
              BaseDropDown<PauseResponsibility>(
                label: 'Responsabilidade da pausa'.hardcoded,
                showLabelAtTopLeft: true,
                items: dropdownResponsibilities,
                selectedItem: selectedResponsibility.value,
                onChanged: (val) => selectedResponsibility.value = val,
              ),
              gapH12,
              BaseStateView<SectorsCubit, SectorsState, List<SectorEntity>>(
                onRetry: () => context.read<SectorsCubit>().loadSectors(),
                dataSelector: (state) => state.sectors,
                builder: (context, sectors) {
                  final dropdownSectors = sectors.map((sec) {
                    return DropdownMenuItem<String>(
                      value: sec.id,
                      child: BaseText.bodyMedium(sec.name),
                    );
                  }).toList();
                  return BaseDropDown<String>(
                    label: 'Setor responsável'.hardcoded,
                    showLabelAtTopLeft: true,
                    hint: BaseText.bodyMedium('Setor responsável'.hardcoded),
                    items: dropdownSectors,
                    selectedItem: selectedSectorId.value,
                    onChanged: (val) => selectedSectorId.value = val,
                    onClear: () => selectedSectorId.value = null,
                  );
                },
              ),
              gapH12,
              BaseTextFormField(
                controller: customReasonController,
                labelText: 'Motivo personalizado (opcional)'.hardcoded,
                hintText: 'Digite um motivo específico se aplicável'.hardcoded,
                maxLength: 100,
                maxLines: 2,
              ),
              gapH12,
              BaseTextFormField(
                controller: observationController,
                labelText: 'Observação (opcional)'.hardcoded,
                hintText: 'Observações adicionais'.hardcoded,
                maxLength: 250,
                maxLines: 5,
              ),
              gapH24,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SecondaryButton(
                    text: 'Cancelar'.hardcoded,
                    onTap: Navigator.of(context).pop,
                    color: Colors.red,
                  ),
                  gapW12,
                  BaseButton(
                    text: (canApprovePause ? 'Pausar' : 'Confirmar').hardcoded,
                    onTap: () async {
                      if (formKey.currentState?.validate() != true) {
                        return;
                      }

                      final success = await cubit.requestPause(
                        workOrderId: workOrderId,
                        reasonId: selectedReason.value?.id,
                        customReason: customReasonController.text.trim().isEmpty
                            ? null
                            : customReasonController.text.trim(),
                        observation: observationController.text.trim().isEmpty
                            ? null
                            : observationController.text.trim(),
                        responsibility: selectedResponsibility.value,
                        sectorId: selectedSectorId.value,
                        workOrdersCubit: context.read<WorkOrdersCubit>(),
                      );
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
