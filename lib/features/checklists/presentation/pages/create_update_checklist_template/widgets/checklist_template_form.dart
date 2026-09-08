import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/create_update_checklist_template/widgets/checklist_template_category_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

/// Name, description and category fields of a checklist template.
class ChecklistTemplateForm extends HookWidget {
  const ChecklistTemplateForm({super.key, this.template});

  final ChecklistTemplateEntity? template;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: template?.name);
    final descriptionController = useTextEditingController(
      text: template?.description,
    );
    final categoryId = useState(template?.categoryId);

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;

      final success = await context
          .read<ChecklistTemplatesCubit>()
          .saveTemplate(
            id: template?.id,
            name: nameController.text,
            description: descriptionController.text,
            categoryId: categoryId.value,
            createdAt: template?.createdAt,
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
            labelText: 'Nome do checklist *'.hardcoded,
            hintText: 'Ex: Inspeção de elevadores'.hardcoded,
            controller: nameController,
            validator: FormValidators.compose([
              NonEmptyValidator(),
              MinLengthValidator(3),
            ]),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
          ),
          gapH16,
          BaseTextFormField(
            labelText: 'Descrição'.hardcoded,
            hintText: 'Quando este checklist deve ser usado'.hardcoded,
            controller: descriptionController,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            maxLength: 1000,
          ),
          gapH16,
          ChecklistTemplateCategoryDropdown(
            selectedId: categoryId.value,
            onChanged: (value) => categoryId.value = value,
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
                  onTap: submit,
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
