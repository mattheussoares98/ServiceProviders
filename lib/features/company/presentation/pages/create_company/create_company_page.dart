import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/cpf_cnpj_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

@RoutePage()
class CreateCompanyPage extends HookWidget {
  const CreateCompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final documentController = useTextEditingController();
    final documentFocusNode = useFocusNode();
    final isLoading = context.select(
      (CompanyCubit cubit) =>
          cubit.state.section(BaseSections.load).isRunning,
    );

    return BaseScaffold(
      appBar: BaseAppBar(title: 'Criar empresa'.hardcoded),
      body: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                gapH20,
                BaseTextFormField(
                  autofocus: true,
                  enabled: !isLoading,
                  labelText: 'Nome'.hardcoded,
                  hintText: 'Digite o nome da empresa'.hardcoded,
                  controller: nameController,
                  validator: FormValidators.compose([NonEmptyValidator()]),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => documentFocusNode.requestFocus(),
                ),
                gapH20,
                BaseTextFormField(
                  enabled: !isLoading,
                  focusNode: documentFocusNode,
                  labelText: 'CPF / CNPJ'.hardcoded,
                  hintText: 'Digite o CPF ou CNPJ'.hardcoded,
                  validator: FormValidators.compose([
                    CpfCnpjValidator(),
                  ]),
                  controller: documentController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(
                    context,
                    formKey,
                    nameController,
                    documentController,
                  ),
                ),
                gapH24,
                BaseButton(
                  isLoading: isLoading,
                  expandWidth: true,
                  onTap: () => _submit(
                    context,
                    formKey,
                    nameController,
                    documentController,
                  ),
                  text: 'SALVAR'.hardcoded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController documentController,
  ) async {
    if (formKey.currentState?.validate() != true) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await context.read<CompanyCubit>().createCompany(
      name: nameController.text,
      document: documentController.text,
    );
  }
}
