import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/pages/create_update_customer/widgets/customer_address_section.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/pages/create_update_customer/widgets/customer_contact_section.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class CustomerForm extends HookWidget {
  const CustomerForm({super.key, this.customer});

  final CustomerEntity? customer;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: customer?.name);
    final documentController = useTextEditingController(
      text: customer?.document,
    );
    final cpfCnpjFocusNode = useFocusNode();
    final contactNameController = useTextEditingController(
      text: customer?.contactName,
    );
    final contactEmailController = useTextEditingController(
      text: customer?.contactEmail,
    );
    final contactPhoneController = useTextEditingController(
      text: customer?.contactPhone,
    );
    final postalCodeController = useTextEditingController(
      text: customer?.postalCode,
    );
    final postalCodeFocusNode = useFocusNode();
    final addressController = useTextEditingController(text: customer?.address);
    final numberController = useTextEditingController(text: customer?.number);
    final complementController = useTextEditingController(
      text: customer?.complement,
    );
    final neighborhoodController = useTextEditingController(
      text: customer?.neighborhood,
    );
    final cityController = useTextEditingController(text: customer?.city);
    final stateController = useTextEditingController(text: customer?.state);
    final notesController = useTextEditingController(text: customer?.notes);
    final isActive = useState(customer?.isActive ?? true);

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;

      final success = await context.read<CustomersCubit>().saveCustomer(
        id: customer?.id,
        name: nameController.text,
        document: documentController.text,
        contactName: contactNameController.text,
        contactEmail: contactEmailController.text,
        contactPhone: contactPhoneController.text,
        postalCode: postalCodeController.text,
        address: addressController.text,
        number: numberController.text,
        complement: complementController.text,
        neighborhood: neighborhoodController.text,
        city: cityController.text,
        stateAddress: stateController.text,
        notes: notesController.text,
        isActive: isActive.value,
        createdAt: customer?.createdAt,
      );

      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          BaseTextFormField(
            controller: nameController,
            labelText: 'Nome do cliente *'.hardcoded,
            validator: FormValidators.compose([NonEmptyValidator()]),
          ),
          gapH12,
          BaseTextFormField(
            controller: documentController,
            labelText: 'CPF / CNPJ'.hardcoded,
            keyboardType: TextInputType.number,
            focusNode: cpfCnpjFocusNode,
          ),
          gapH16,
          CustomerContactSection(
            contactNameController: contactNameController,
            contactEmailController: contactEmailController,
            contactPhoneController: contactPhoneController,
            notesController: notesController,
          ),
          gapH16,
          CustomerAddressSection(
            postalCodeController: postalCodeController,
            addressController: addressController,
            numberController: numberController,
            complementController: complementController,
            neighborhoodController: neighborhoodController,
            cityController: cityController,
            stateController: stateController,
            postalCodeFocusNode: postalCodeFocusNode,
          ),
          gapH24,
          BaseButton(text: 'Salvar'.hardcoded, onTap: submit),
          gapH24,
        ],
      ),
    );
  }
}
