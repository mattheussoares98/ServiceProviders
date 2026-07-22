import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/cpf_cnpj_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class CreateServiceProviderCompanyDialog extends HookWidget {
  const CreateServiceProviderCompanyDialog({
    super.key,
    required this.onCompanyChanged,
  });
  final void Function(String value) onCompanyChanged;

  static Future<void> show(
    BuildContext context, {
    required void Function(String value) onCompanyChanged,
  }) {
    return showModalPage(
      CreateServiceProviderCompanyDialog(onCompanyChanged: onCompanyChanged),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final documentController = useTextEditingController();
    final documentFocusNode = useFocusNode();
    final documentType = useState<String?>(null);

    Future<void> onSubmit() async {
      if (formKey.currentState?.validate() != true) return;
      final now = DateTime.now();
      final result = ServiceProviderCompanyEntity(
        id: '', //TODO move this to the cubit
        companyId: '', // Will be set by the calling side before save
        name: nameController.text.trim(),
        contactEmail: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        contactPhone: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        document: documentController.text.trim().isEmpty
            ? null
            : documentController.text.trim(),
        documentType: documentType.value,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      //TODO should save in the CreateServiceProviderCompanyDialog to avoid losing the data then it throws
      if (context.mounted) {
        final sessionUser = context.read<SessionCubit>().state.user;
        final company = result.copyWith(companyId: sessionUser.companyId);
        final cubit = context.read<ServiceProvidersCubit>();
        final success = await cubit.saveCompany(company);
        if (success && context.mounted) {
          final newCompany = cubit.state.companies.firstWhereOrNull(
            (c) => c.name == company.name,
          );
          if (newCompany != null) {
            onCompanyChanged(newCompany.id);
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(Sizes.p8),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseText.title('Novo prestador de serviço (empresa)'.hardcoded),
            BaseTextFormField(
              labelText: 'Nome *'.hardcoded,
              controller: nameController,
              validator: FormValidators.compose([NonEmptyValidator()]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            gapH12,
            BaseTextFormField(
              labelText: 'E-mail de contato'.hardcoded,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            gapH12,
            BaseTextFormField(
              labelText: 'Telefone de contato'.hardcoded,
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
            gapH12,
            BaseDropDown<String>(
              selectedItem: documentType.value,
              label: 'Tipo de documento'.hardcoded,
              items: [
                DropdownMenuItem(
                  value: 'cpf',
                  child: BaseText('CPF'.hardcoded),
                ),
                DropdownMenuItem(
                  value: 'cnpj',
                  child: BaseText('CNPJ'.hardcoded),
                ),
              ],
              onChanged: (val) => documentType.value = val,
            ),
            gapH12,
            BaseTextFormField(
              labelText: documentType.value == 'cpf'
                  ? 'CPF'.hardcoded
                  : 'CNPJ'.hardcoded,
              controller: documentController,
              focusNode: documentFocusNode,
              keyboardType: TextInputType.number,
              maxLength: documentType.value == 'cpf' ? 11 : 14,
              validator: FormValidators.compose([
                CpfCnpjValidator(
                  validateOnlyCnpj: documentType.value == 'cnpj',
                  validateOnlyCpf: documentType.value == 'cpf',
                ),
              ]),
            ),
            gapH12,
            Row(
              mainAxisAlignment: .spaceEvenly,
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
                    onTap: onSubmit,
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
