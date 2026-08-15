import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class RequestPauseFields extends HookWidget {
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

    final dropdownResponsibilities = PauseResponsibility.values.map((resp) {
      return DropdownMenuItem<PauseResponsibility>(
        value: resp,
        child: BaseText.bodyMedium(resp.label),
      );
    }).toList();

    return BlocProvider.value(
      value: cubit,
      child: BaseScaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseText.titleMedium(
              'Solicitar pausa'.hardcoded,
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
                      customReason: customReasonController.text.trim().isEmpty
                          ? null
                          : customReasonController.text.trim(),
                      observation: observationController.text.trim().isEmpty
                          ? null
                          : observationController.text.trim(),
                      responsibility: selectedResponsibility.value,
                      sectorId: selectedSectorId.value,
                    );
                    if (success && context.mounted) {
                      await context
                          .read<WorkOrdersCubit>()
                          .loadWorkOrdersAndChangeRequests(showLoading: false);
                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
