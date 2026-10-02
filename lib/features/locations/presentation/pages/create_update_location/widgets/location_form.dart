import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/address_form_section.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class LocationForm extends StatelessWidget {
  const LocationForm({
    super.key,
    required this.formKey,
    required this.existingLocation,
    required this.nameController,
    required this.cepController,
    required this.addressController,
    required this.numberController,
    required this.complementController,
    required this.neighborhoodController,
    required this.cityController,
    required this.stateController,
    required this.cepFocusNode,
    required this.addressFocusNode,
    required this.numberFocusNode,
    required this.complementFocusNode,
    required this.neighborhoodFocusNode,
    required this.cityFocusNode,
    required this.stateFocusNode,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final LocationEntity? existingLocation;
  final TextEditingController nameController;
  final TextEditingController cepController;
  final TextEditingController addressController;
  final TextEditingController numberController;
  final TextEditingController complementController;
  final TextEditingController neighborhoodController;
  final TextEditingController cityController;
  final TextEditingController stateController;

  final FocusNode cepFocusNode;
  final FocusNode addressFocusNode;
  final FocusNode numberFocusNode;
  final FocusNode complementFocusNode;
  final FocusNode neighborhoodFocusNode;
  final FocusNode cityFocusNode;
  final FocusNode stateFocusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isSearchingCep = context.select<LocationsCubit, bool>(
      (c) =>
          c.state.sections[LocationsSections.loadAddressByCep] ==
          const SectionState.running(),
    );

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BaseTextFormField(
              labelText: 'Nome do Local *'.hardcoded,
              hintText: 'Ex: Sede Central'.hardcoded,
              controller: nameController,
              validator: FormValidators.compose([NonEmptyValidator()]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => cepFocusNode.requestFocus(),
            ),
            gapH16,
            AddressFormSection(
              postalCodeController: cepController,
              addressController: addressController,
              numberController: numberController,
              complementController: complementController,
              neighborhoodController: neighborhoodController,
              cityController: cityController,
              stateController: stateController,
              postalCodeFocusNode: cepFocusNode,
              addressFocusNode: addressFocusNode,
              numberFocusNode: numberFocusNode,
              complementFocusNode: complementFocusNode,
              neighborhoodFocusNode: neighborhoodFocusNode,
              cityFocusNode: cityFocusNode,
              stateFocusNode: stateFocusNode,
              isSearchingCep: isSearchingCep,
              requirePostalCode: false,
              onSearchCep: (cep) =>
                  context.read<LocationsCubit>().getAddressByCep(cep),
            ),
            gapH24,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: BaseButton.text(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Cancelar'.hardcoded,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  child: BaseButton(
                    onTap: onSubmit,
                    width: Sizes.p120,
                    text: 'Salvar'.hardcoded,
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
