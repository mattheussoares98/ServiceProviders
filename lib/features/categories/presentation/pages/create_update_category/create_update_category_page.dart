import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';
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
        Navigator.of(context).pop();
      }
    }

    final isEditing = category != null;

    return BaseScaffold(
      appBar: BaseAppBar(
        title: isEditing
            ? 'Editando categoria'.hardcoded
            : 'Criando categoria'.hardcoded,
        actions: [
          if (category != null)
            BaseIconButton(
              permission: const ActionPermission.resource(
                resource: ResourceType.categories,
                action: PermissionAction.delete,
              ),
              onPressed: () {
                showAlertDialog(
                  context: context,
                  title: 'Atenção!'.hardcoded,
                  contentText:
                      'Deseja realmente excluir a categoria "${category!.name}"?'
                          .hardcoded,
                  defaultActionText: 'Sim'.hardcoded,
                  cancelActionText: 'Não'.hardcoded,
                  onOkPressed: () => context
                      //TODO should return a bool value and close the page on success
                      .read<CategoriesCubit>()
                      .deleteCategory(category!.id),
                );
              },
              platformIcon: const PlatformIcon(
                materialIcon: Icons.delete_outline,
                cupertinoIcon: CupertinoIcons.trash,
                color: Colors.red,
              ),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            BaseTextFormField(
              labelText: 'Nome da categoria *'.hardcoded,
              hintText: 'Ex: elétrica'.hardcoded,
              controller: nameController,
              maxLength: 100,
              validator: FormValidators.compose([
                NonEmptyValidator(),
                MinLengthValidator(3),
              ]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => descriptionFocusNode.requestFocus(),
            ),
            gapH16,
            BaseTextFormField(
              labelText: 'Descrição (opcional)'.hardcoded,
              hintText: 'Ex: manutenção elétrica em geral'.hardcoded,
              controller: descriptionController,
              focusNode: descriptionFocusNode,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => submit(),
              maxLength: 500,
              maxLines: 10,
            ),
            gapH24,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: BaseTextButton(
                    onPressed: Navigator.of(context).pop,
                    text: 'Cancelar'.hardcoded,
                    color: Colors.red,
                  ),
                ),
                gapW12,
                Expanded(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      nameController,
                      descriptionController,
                    ]),
                    builder: (context, child) {
                      final hasChanges =
                          nameController.text.trim() !=
                              (category?.name.trim() ?? '') ||
                          descriptionController.text.trim() !=
                              (category?.description?.trim() ?? '');

                      return BaseButton(
                        onTap: hasChanges ? submit : null,
                        text: 'Salvar'.hardcoded,
                      );
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
