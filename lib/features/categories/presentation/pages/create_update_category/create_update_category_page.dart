import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

@RoutePage()
class CreateUpdateCategoryPage extends HookWidget {
  const CreateUpdateCategoryPage({super.key, this.category});

  final CategoryEntity? category;

  @override
  Widget build(BuildContext context) {
    observeLoading(
      [context.read<CategoriesCubit>()],
      statuses: {StateStatus.saving, StateStatus.deleting},
    );

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: category?.name);
    final descriptionController = useTextEditingController(
      text: category?.description,
    );
    final descriptionFocusNode = useFocusNode();

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;

      final success = await context.read<CategoriesCubit>().saveCategory(
        id: category?.id,
        name: nameController.text,
        description: descriptionController.text,
        color: category?.color,
        createdAt: category?.createdAt,
      );

      if (success && context.mounted) {
        Navigator.of(context).pop(true);
      }
    }

    final isEditing = category != null;

    return BaseScaffold(
      appBar: BaseAppBar(
        title: isEditing
            ? 'Editando categoria'.hardcoded
            : 'Criando categoria'.hardcoded,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BaseTextFormField(
                labelText: 'Nome da Categoria *'.hardcoded,
                hintText: 'Ex: Elétrica'.hardcoded,
                controller: nameController,
                validator: FormValidators.compose([NonEmptyValidator()]),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => descriptionFocusNode.requestFocus(),
              ),
              gapH16,
              BaseTextFormField(
                labelText: 'Descrição (Opcional)'.hardcoded,
                hintText: 'Ex: Manutenção elétrica em geral'.hardcoded,
                controller: descriptionController,
                focusNode: descriptionFocusNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => submit(),
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
        ),
      ),
    );
  }
}
