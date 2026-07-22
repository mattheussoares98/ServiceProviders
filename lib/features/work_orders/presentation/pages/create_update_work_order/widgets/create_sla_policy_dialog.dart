import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/sla_applies_to.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class CreateSlaPolicyDialog extends HookWidget {
  const CreateSlaPolicyDialog({super.key});

  static Future<SlaPolicyEntity?> show(BuildContext context) {
    return showModalPage(const CreateSlaPolicyDialog(), context);
  }

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final hoursController = useTextEditingController();
    final hoursFocusNode = useFocusNode();
    final appliesTo = useState<SlaAppliesTo>(SlaAppliesTo.both);
    //TODO improve this widget
    return Padding(
      padding: const EdgeInsets.all(Sizes.p8),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseText.title('Nova política de SLA'.hardcoded),
            BaseTextFormField(
              labelText: 'Nome *'.hardcoded,
              controller: nameController,
              validator: FormValidators.compose([NonEmptyValidator()]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            gapH8,
            BaseTextFormField(
              labelText: 'Horas limite *'.hardcoded,
              controller: hoursController,
              focusNode: hoursFocusNode,
              keyboardType: TextInputType.number,
              validator: FormValidators.compose([NonEmptyValidator()]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            gapH12,
            BaseDropDown<SlaAppliesTo>(
              selectedItem: appliesTo.value,
              showLabelAtTopLeft: true,
              label: 'Aplica-se a *'.hardcoded,
              items: SlaAppliesTo.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: BaseText(e.label.hardcoded),
                    ),
                  )
                  .toList(),
              onChanged: (val) => appliesTo.value = val,
            ),
            gapH12,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: BaseTextButton(
                    text: 'Cancelar'.hardcoded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                gapW8,
                Flexible(
                  child: PrimaryButton(
                    text: 'Salvar'.hardcoded,
                    onTap: () {
                      if (formKey.currentState?.validate() != true) return;
                      final targetHours =
                          int.tryParse(hoursController.text) ?? 0;
                      final entity = SlaPolicyEntity(
                        id: '',
                        companyId: '',
                        name: nameController.text.trim(),
                        targetHours: targetHours,
                        appliesTo: appliesTo.value,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      Navigator.of(context).pop(entity);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
