import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class CustomerAddressSection extends StatelessWidget {
  const CustomerAddressSection({
    super.key,
    required this.postalCodeController,
    required this.addressController,
    required this.numberController,
    required this.complementController,
    required this.neighborhoodController,
    required this.cityController,
    required this.stateController,
    this.postalCodeFocusNode,
  });

  final TextEditingController postalCodeController;
  final TextEditingController addressController;
  final TextEditingController numberController;
  final TextEditingController complementController;
  final TextEditingController neighborhoodController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final FocusNode? postalCodeFocusNode;

  Future<void> _onCepChanged(BuildContext context, String value) async {
    final cleanCep = value.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length == 8) {
      final address = await context.read<CustomersCubit>().getAddressByCep(
        cleanCep,
      );
      if (address != null) {
        addressController.text = address.street;
        neighborhoodController.text = address.neighborhood;
        cityController.text = address.city;
        stateController.text = address.state;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO change focus automatically to number when searching succeeds and disable street, city, neighborhood and state
    //TODO use a default widget to mount this AddressEntity
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText.titleMedium('Endereço'.hardcoded),
        gapH12,
        BaseTextFormField(
          controller: postalCodeController,
          labelText: 'CEP'.hardcoded,
          keyboardType: TextInputType.number,
          focusNode: postalCodeFocusNode,
          onChanged: (val) => _onCepChanged(context, val),
        ),
        gapH12,
        Row(
          children: [
            Expanded(
              flex: 3,
              child: BaseTextFormField(
                controller: addressController,
                labelText: 'Logradouro / Rua'.hardcoded,
              ),
            ),
            gapW12,
            Expanded(
              child: BaseTextFormField(
                controller: numberController,
                labelText: 'Número'.hardcoded,
              ),
            ),
          ],
        ),
        gapH12,
        Row(
          children: [
            Expanded(
              child: BaseTextFormField(
                controller: complementController,
                labelText: 'Complemento'.hardcoded,
              ),
            ),
            gapW12,
            Expanded(
              child: BaseTextFormField(
                controller: neighborhoodController,
                labelText: 'Bairro'.hardcoded,
              ),
            ),
          ],
        ),
        gapH12,
        Row(
          children: [
            Expanded(
              flex: 2,
              child: BaseTextFormField(
                controller: cityController,
                labelText: 'Cidade'.hardcoded,
              ),
            ),
            gapW12,
            Expanded(
              child: BaseTextFormField(
                controller: stateController,
                labelText: 'UF / Estado'.hardcoded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
