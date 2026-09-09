import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/extensions/checklist_item_type_ui_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/create_update_checklist_item/widgets/checklist_item_options_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_switch.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

/// Configures a checklist item: its label, answer type, options and whether it
/// must be answered before the work order can be completed.
class ChecklistItemForm extends HookWidget {
  const ChecklistItemForm({
    super.key,
    required this.templateId,
    required this.initialType,
    required this.sortOrder,
    this.item,
  });

  final String templateId;
  final ChecklistItemType initialType;
  final int sortOrder;
  final ChecklistItemEntity? item;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final labelController = useTextEditingController(text: item?.label);
    final type = useState(initialType);
    final isRequired = useState(item?.isRequired ?? false);
    final options = useState<List<String>>([...?item?.options]);

    final needsOptions =
        type.value == ChecklistItemType.selection ||
        type.value == ChecklistItemType.multiSelection;

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;
      if (needsOptions && options.value.isEmpty) return;

      final success = await context.read<ChecklistTemplatesCubit>().saveItem(
        id: item?.id,
        templateId: templateId,
        label: labelController.text,
        type: type.value,
        isRequired: isRequired.value,
        options: needsOptions ? options.value : null,
        sortOrder: sortOrder,
        createdAt: item?.createdAt,
      );

      if (success && context.mounted) Navigator.of(context).pop();
    }

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BaseTextFormField(
            labelText: 'Pergunta *'.hardcoded,
            hintText: 'Ex: O extintor está dentro da validade?'.hardcoded,
            controller: labelController,
            maxLength: 500,
            validator: FormValidators.compose([
              NonEmptyValidator(),
              MinLengthValidator(3),
            ]),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
          ),
          gapH16,
          BaseDropDown<ChecklistItemType>(
            key: const ValueKey('ChecklistItemType'),
            showLabelAtTopLeft: true,
            label: 'Tipo de resposta *'.hardcoded,
            hint: BaseText.bodyMedium('Selecione o tipo'.hardcoded),
            selectedItem: type.value,
            items: ChecklistItemType.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: BaseText(value.label),
                  ),
                )
                .toList(),
            onChanged: (value) => type.value = value,
          ),
          if (needsOptions) ...[
            gapH16,
            ChecklistItemOptionsField(
              options: options.value,
              onChanged: (value) => options.value = value,
            ),
          ],
          gapH8,
          BaseSwitch(
            title: 'Resposta obrigatória'.hardcoded,
            value: isRequired.value,
            onChanged: (value) => isRequired.value = value,
          ),
          gapH24,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: BaseTextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  text: 'Cancelar'.hardcoded,
                  color: Colors.red,
                ),
              ),
              gapW12,
              Expanded(
                child: BaseButton(
                  onTap: needsOptions && options.value.isEmpty ? null : submit,
                  width: Sizes.p120,
                  text: 'Salvar'.hardcoded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
