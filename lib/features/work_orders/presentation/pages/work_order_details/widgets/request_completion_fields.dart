import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class RequestCompletionFields extends HookWidget {
  const RequestCompletionFields({
    required this.companyId,
    required this.workOrderId,
    required this.currentUserId,
    super.key,
  });

  final String companyId;
  final String workOrderId;
  final String currentUserId;
  //TODO check this entire code
  @override
  Widget build(BuildContext context) {
    final cubit = useMemoized(() => GetIt.I<PauseWorkflowCubit>());

    useEffect(() {
      cubit.loadSectors(companyId);
      return null;
    }, []);

    final selectedResponsibility = useState<PauseResponsibility>(
      PauseResponsibility.provider,
    );
    final selectedSectorId = useState<String?>(null);
    final reasonController = useTextEditingController();
    final observationController = useTextEditingController();

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<PauseWorkflowCubit, PauseWorkflowState>(
        builder: (context, state) {
          final dropdownResponsibilities = PauseResponsibility.values.map((
            resp,
          ) {
            return DropdownMenuItem<PauseResponsibility>(
              value: resp,
              child: BaseText.bodyMedium(resp.label),
            );
          }).toList();

          final dropdownSectors = state.sectors.map((sec) {
            return DropdownMenuItem<String>(
              value: sec.id,
              child: BaseText.bodyMedium(sec.name),
            );
          }).toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BaseText.titleMedium(
                'Solicitar conclusão'.hardcoded,
                fontWeight: FontWeight.bold,
              ),
              gapH16,
              BaseTextFormField(
                controller: reasonController,
                labelText: 'Justificativa de conclusão'.hardcoded,
                hintText:
                    'Descreva o trabalho realizado / justificativa'.hardcoded,
                maxLength: 250,
                maxLines: 2,
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
              gapH12,
              BaseDropDown<String>(
                label: 'Setor destino'.hardcoded,
                hint: BaseText.bodyMedium('Selecione o setor'.hardcoded),
                items: dropdownSectors,
                selectedItem: selectedSectorId.value,
                onChanged: (val) {
                  selectedSectorId.value = val;
                },
              ),
              gapH12,
              BaseTextFormField(
                controller: observationController,
                labelText: 'Observação adicional (opcional)'.hardcoded,
                hintText: 'Observações sobre a entrega do serviço'.hardcoded,
                maxLength: 250,
                maxLines: 2,
              ),
              gapH24,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    text: 'Cancelar'.hardcoded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  gapW12,
                  BaseButton(
                    text: 'Confirmar'.hardcoded,
                    onTap: () async {
                      if (reasonController.text.trim().isEmpty) {
                        cubit.showErrorToast(
                          'Por favor, informe a justificativa de conclusão.'
                              .hardcoded,
                        );
                        return;
                      }

                      final success = await cubit.requestCompletion(
                        companyId: companyId,
                        workOrderId: workOrderId,
                        requestedById: currentUserId,
                        customReason: reasonController.text.trim(),
                        responsibility: selectedResponsibility.value,
                        sectorId: selectedSectorId.value,
                        observation: observationController.text.trim().isEmpty
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
          );
        },
      ),
    );
  }
}
