import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class RequestCompletionFields extends HookWidget {
  const RequestCompletionFields({required this.workOrderId, super.key});

  final String workOrderId;

  @override
  Widget build(BuildContext context) {
    final selectedSectorId = useState<String?>(null);
    final reasonController = useTextEditingController();
    final observationController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return Padding(
      padding: const EdgeInsets.all(Sizes.p12),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseText.titleMedium(
              'Solicitar conclusão'.hardcoded,
              fontWeight: FontWeight.bold,
            ),
            gapH16,
            BaseTextFormField(
              validator: FormValidators.compose([
                NonEmptyValidator(),
                MinLengthValidator(3),
              ]),
              controller: reasonController,
              labelText: 'Justificativa de conclusão'.hardcoded,
              hintText:
                  'Descreva o trabalho realizado / justificativa'.hardcoded,
              maxLength: 250,
              maxLines: 5,
            ),
            gapH12,
            BaseStateView<SectorsCubit, SectorsState, List<SectorEntity>>(
              dataSelector: (state) => state.sectors,
              onRetry: context.read<SectorsCubit>().loadSectors,
              builder: (context, sectors) {
                final dropdownSectors = sectors.map((sec) {
                  return DropdownMenuItem<String>(
                    value: sec.id,
                    child: BaseText.bodyMedium(sec.name),
                  );
                }).toList();

                return BaseDropDown<String>(
                  label: 'Setor destino'.hardcoded,
                  hint: BaseText.bodyMedium('Selecione o setor'.hardcoded),
                  items: dropdownSectors,
                  selectedItem: selectedSectorId.value,
                  onChanged: (val) {
                    selectedSectorId.value = val;
                  },
                );
              },
            ),
            gapH12,
            BaseTextFormField(
              controller: observationController,
              labelText: 'Observação adicional (opcional)'.hardcoded,
              hintText: 'Observações sobre a entrega do serviço'.hardcoded,
              maxLength: 250,
              maxLines: 5,
            ),
            gapH24,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SecondaryButton(
                  text: 'Cancelar'.hardcoded,
                  onTap: Navigator.of(context).pop,
                  color: Colors.red,
                ),
                gapW12,
                BaseButton(
                  text: 'Confirmar'.hardcoded,
                  onTap: () async {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }

                    final cubit = context.read<PauseWorkflowCubit>();

                    final success = await cubit.requestCompletion(
                      workOrderId: workOrderId,
                      customReason: reasonController.text.trim(),
                      sectorId: selectedSectorId.value,
                      observation: observationController.text.trim().isEmpty
                          ? null
                          : observationController.text.trim(),
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
    );
  }
}
