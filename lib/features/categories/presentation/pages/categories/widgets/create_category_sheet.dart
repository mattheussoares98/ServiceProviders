import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CreateCategorySheet extends HookWidget {
  const CreateCategorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final nameFocusNode = useFocusNode();

    final categoriesCubit = context.read<CategoriesCubit>();

    observeLoading([categoriesCubit], statuses: {StateStatus.saving});

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;

      final success = await categoriesCubit.saveCategory(
        id: null,
        name: nameController.text,
      );

      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: Sizes.p16,
        right: Sizes.p16,
        top: Sizes.p16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Sizes.p16,
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nova Categoria'.hardcoded,
                style: context.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              gapH16,
              BaseTextFormField(
                labelText: 'Nome da categoria'.hardcoded,
                hintText: 'Ex: Ar Condicionado'.hardcoded,
                controller: nameController,
                focusNode: nameFocusNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => submit(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome da categoria é obrigatório'.hardcoded;
                  }
                  return null;
                },
              ),
              gapH24,
              PrimaryButton(onTap: submit, text: 'Salvar'.hardcoded),
            ],
          ),
        ),
      ),
    );
  }
}
