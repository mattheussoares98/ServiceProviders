import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class RequestPauseFields extends HookWidget {
  //TODO review this entire page
  const RequestPauseFields({
    required this.companyId,
    required this.workOrderId,
    required this.currentUserId,
    super.key,
  });

  final String companyId;
  final String workOrderId;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PauseWorkflowCubit>();

    final selectedReason = useState<PauseReasonEntity?>(null);
    final selectedResponsibility = useState<PauseResponsibility>(
      PauseResponsibility.provider,
    );
    final selectedSectorId = useState<String?>(null);
    final customReasonController = useTextEditingController();
    final observationController = useTextEditingController();

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<PauseWorkflowCubit, PauseWorkflowState>(
        builder: (context, state) {
          final dropdownReasons = state.pauseReasons.map((reason) {
            return DropdownMenuItem<PauseReasonEntity>(
              value: reason,
              child: BaseText.bodyMedium(reason.name),
            );
          }).toList();

          final dropdownResponsibilities = PauseResponsibility.values.map((
            resp,
          ) {
            return DropdownMenuItem<PauseResponsibility>(
              value: resp,
              child: BaseText.bodyMedium(resp.label),
            );
          }).toList();

          final sectors = context.select(
            (SectorsCubit cubit) => cubit.state.sectors,
          );
          final dropdownSectors = sectors.map((sec) {
            return DropdownMenuItem<String>(
              value: sec.id,
              child: BaseText.bodyMedium(sec.name),
            );
          }).toList();

          return BaseScaffold(
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BaseText.titleMedium(
                  'Solicitar pausa'.hardcoded,
                  fontWeight: FontWeight.bold,
                ),
                gapH16,
                BaseDropDown<PauseReasonEntity>(
                  label: 'Motivo da pausa'.hardcoded,
                  showLabelAtTopLeft: true,
                  hint: BaseText.bodyMedium('Selecione um motivo'.hardcoded),
                  items: dropdownReasons,
                  selectedItem: selectedReason.value,
                  onClear: () => selectedReason.value = null,
                  onChanged: (val) {
                    selectedReason.value = val;
                  },
                ),
                gapH12,
                BaseDropDown<PauseResponsibility>(
                  label: 'Responsabilidade da pausa'.hardcoded,
                  showLabelAtTopLeft: true,
                  items: dropdownResponsibilities,
                  selectedItem: selectedResponsibility.value,
                  onChanged: (val) {
                    selectedResponsibility.value = val;
                  },
                ),
                gapH12,
                BaseDropDown<String>(
                  label: 'Setor responsável'.hardcoded,
                  showLabelAtTopLeft: true,
                  hint: BaseText.bodyMedium('Setor responsável'.hardcoded),
                  items: dropdownSectors,
                  selectedItem: selectedSectorId.value,
                  onChanged: (val) {
                    selectedSectorId.value = val;
                  },
                  onClear: () => selectedSectorId.value = null,
                ),
                gapH12,
                BaseTextFormField(
                  controller: customReasonController,
                  labelText: 'Motivo personalizado (opcional)'.hardcoded,
                  hintText:
                      'Digite um motivo específico se aplicável'.hardcoded,
                  maxLength: 100,
                ),
                gapH12,
                BaseTextFormField(
                  controller: observationController,
                  labelText: 'Observação (opcional)'.hardcoded,
                  hintText: 'Observações adicionais'.hardcoded,
                  maxLength: 250,
                  maxLines: 3,
                ),
                gapH24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BaseTextButton(
                      text: 'Cancelar'.hardcoded,
                      onPressed: Navigator.of(context).pop,
                      color: Colors.red,
                    ),
                    gapW12,
                    BaseButton(
                      text: 'Confirmar'.hardcoded,
                      onTap: () async {
                        final success = await cubit.requestPause(
                          companyId: companyId,
                          workOrderId: workOrderId,
                          requestedById: currentUserId,
                          reasonId: selectedReason.value?.id,
                          customReason:
                              customReasonController.text.trim().isEmpty
                              ? null
                              : customReasonController.text.trim(),
                          observation: observationController.text.trim().isEmpty
                              ? null
                              : observationController.text.trim(),
                          responsibility: selectedResponsibility.value,
                          sectorId: selectedSectorId.value,
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
          );
        },
      ),
    );
  }
}
