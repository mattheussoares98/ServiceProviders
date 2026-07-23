import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
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
      BlocProvider.value(
        value: context.read<ServiceProvidersCubit>(),
        child: CreateServiceProviderCompanyDialog(
          onCompanyChanged: onCompanyChanged,
        ),
      ),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    observeLoading(
      [context.read<ServiceProvidersCubit>()],
      statuses: {StateStatus.saving},
    );
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final phoneController = useTextEditingController();
    final documentController = useTextEditingController();
    final documentFocusNode = useFocusNode();
    final documentType = useState<DocumentType>(DocumentType.cnpj);

    Future<void> onSubmit() async {
      if (formKey.currentState?.validate() != true) return;
      final name = nameController.text.trim();
      final contactEmail = emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim();
      final contactPhone = phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim();
      final document = documentController.text.trim();
      final docType = documentType.value;

      if (context.mounted) {
        final cubit = context.read<ServiceProvidersCubit>();
        final success = await cubit.saveCompany(
          name: name,
          contactEmail: contactEmail,
          contactPhone: contactPhone,
          document: document,
          documentType: docType,
        );
        if (success && context.mounted) {
          final newCompany = cubit.state.companies.firstWhereOrNull(
            (c) => c.name == name,
          );
          if (newCompany != null) {
            onCompanyChanged(newCompany.id);
          }
          Navigator.of(context).pop();
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
            BaseDropDown<DocumentType>(
              selectedItem: documentType.value,
              label: 'Tipo de documento'.hardcoded,
              items: [
                DropdownMenuItem(
                  value: DocumentType.cpf,
                  child: BaseText(
                    DocumentType.cpf.name.toUpperCase().hardcoded,
                  ),
                ),
                DropdownMenuItem(
                  value: DocumentType.cnpj,
                  child: BaseText(
                    DocumentType.cnpj.name.toUpperCase().hardcoded,
                  ),
                ),
              ],
              onChanged: (val) => documentType.value = val,
            ),
            gapH12,
            BaseTextFormField(
              labelText: documentType.value == DocumentType.cpf
                  ? 'CPF'.hardcoded
                  : 'CNPJ'.hardcoded,
              controller: documentController,
              focusNode: documentFocusNode,
              keyboardType: TextInputType.number,
              maxLength: documentType.value == DocumentType.cpf ? 11 : 14,
              autovalidateMode: AutovalidateMode.onUserInteractionIfError,
              validator: FormValidators.compose([
                CpfCnpjValidator(
                  validateOnlyCnpj: documentType.value == DocumentType.cnpj,
                  validateOnlyCpf: documentType.value == DocumentType.cpf,
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
