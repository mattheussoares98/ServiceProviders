import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_checkbox.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/cpf_cnpj_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/ddd_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/email_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/number_validator.dart';

part 'widgets/cpf_cnpj_field.dart';
part 'widgets/ddd_and_phone_fields.dart';
part 'widgets/document_dropdown.dart';
part 'widgets/name_and_email_fields.dart';
part 'widgets/send_email_invitation_checkbox.dart';

@RoutePage()
class CreateUpdateServiceProviderCompanyPage extends HookWidget {
  const CreateUpdateServiceProviderCompanyPage({
    super.key,
    this.serviceProviderCompanyId,
  });

  final String? serviceProviderCompanyId;

  @override
  Widget build(BuildContext context) {
    observeLoading([
      ObservedLoadingTarget(
        context.read<ServiceProvidersCubit>(),
        sections: const {
          ServiceProvidersSections.saveCompany: {SectionStatus.running},
        },
      ),
    ]);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final dddController = useTextEditingController();
    final phoneController = useTextEditingController();
    final documentController = useTextEditingController();
    final documentFocusNode = useFocusNode();
    final emailFocusNode = useFocusNode();
    final dddFocusNode = useFocusNode();
    final phoneFocusNode = useFocusNode();

    useListenable(nameController);
    useListenable(emailController);
    useListenable(dddController);
    useListenable(phoneController);
    useListenable(documentController);

    final documentType = useState<DocumentType>(DocumentType.cnpj);
    final sendInvite = useState<bool>(false);
    final isInitialized = useState<bool>(false);
    final initialCompany = useState<ServiceProviderCompanyEntity?>(null);

    final isEdit =
        serviceProviderCompanyId != null &&
        serviceProviderCompanyId!.isNotEmpty;

    final companies = context.select(
      (ServiceProvidersCubit cubit) => cubit.state.companies,
    );

    useEffect(() {
      if (isEdit && !isInitialized.value && companies.isNotEmpty) {
        final company = companies.firstWhereOrNull(
          (c) => c.id == serviceProviderCompanyId,
        );
        if (company != null) {
          initialCompany.value = company;
          nameController.text = company.name;
          emailController.text = company.contactEmail ?? '';
          if (company.contactPhone != null &&
              company.contactPhone!.length >= 10) {
            dddController.text = company.contactPhone!.substring(0, 2);
            phoneController.text = company.contactPhone!.substring(2);
          } else {
            dddController.text = '';
            phoneController.text = company.contactPhone ?? '';
          }
          documentController.text = company.document;
          documentType.value = company.documentType;
          isInitialized.value = true;
        }
      }
      return null;
    }, [isEdit, companies, serviceProviderCompanyId]);

    final bool hasChanges;
    if (isEdit && initialCompany.value != null) {
      final init = initialCompany.value!;
      final currentEmail = emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim();
      final rawPhone =
          '${dddController.text.trim()}${phoneController.text.trim()}';
      final currentPhone = rawPhone.isEmpty ? null : rawPhone;

      hasChanges =
          nameController.text.trim() != init.name ||
          currentEmail != init.contactEmail ||
          currentPhone != init.contactPhone ||
          documentController.text.trim() != init.document ||
          documentType.value != init.documentType ||
          sendInvite.value;
    } else {
      hasChanges =
          nameController.text.trim().isNotEmpty ||
          emailController.text.trim().isNotEmpty ||
          dddController.text.trim().isNotEmpty ||
          phoneController.text.trim().isNotEmpty ||
          documentController.text.trim().isNotEmpty;
    }

    Future<void> onSubmit() async {
      if (formKey.currentState?.validate() != true) return;
      final name = nameController.text.trim();
      final contactEmail = emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim();
      final rawPhone =
          '${dddController.text.trim()}${phoneController.text.trim()}';
      final contactPhone = rawPhone.isEmpty ? null : rawPhone;
      final document = documentController.text.trim();
      final docType = documentType.value;

      if (context.mounted) {
        final cubit = context.read<ServiceProvidersCubit>();
        final success = await cubit.saveCompany(
          serviceProviderCompanyId: serviceProviderCompanyId,
          name: name,
          contactEmail: contactEmail,
          contactPhone: contactPhone,
          document: document,
          documentType: docType,
          sendInvite: sendInvite.value,
        );
        if (success && context.mounted) {
          Navigator.of(context).pop();
        }
      }
    }

    return BaseScaffold(
      appBar: BaseAppBar(
        title: isEdit
            ? 'Editar prestador de serviço'.hardcoded
            : 'Novo prestador de serviço (empresa)'.hardcoded,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _NameAndEmailFields(
                nameController: nameController,
                emailController: emailController,
                emailFocusNode: emailFocusNode,
                dddFocusNode: dddFocusNode,
              ),
              gapH8,
              _SendEmailInvitationCheckbox(
                emailController: emailController,
                sendInvite: sendInvite,
              ),
              gapH12,
              _DddAndPhoneFields(
                dddController: dddController,
                dddFocusNode: dddFocusNode,
                phoneController: phoneController,
                phoneFocusNode: phoneFocusNode,
                documentFocusNode: documentFocusNode,
              ),
              gapH12,
              _DocumentDropdown(documentType: documentType),
              gapH12,
              _CpfCnpjField(
                documentType: documentType,
                documentController: documentController,
                documentFocusNode: documentFocusNode,
              ),
              gapH24,
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
                    child: BaseButton(
                      text: 'Salvar'.hardcoded,
                      onTap: hasChanges ? onSubmit : null,
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
