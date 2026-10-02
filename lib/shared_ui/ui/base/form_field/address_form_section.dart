import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/address_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

class AddressFormSection extends StatefulWidget {
  const AddressFormSection({
    super.key,
    required this.postalCodeController,
    required this.addressController,
    required this.numberController,
    required this.complementController,
    required this.neighborhoodController,
    required this.cityController,
    required this.stateController,
    this.postalCodeFocusNode,
    this.addressFocusNode,
    this.numberFocusNode,
    this.complementFocusNode,
    this.neighborhoodFocusNode,
    this.cityFocusNode,
    this.stateFocusNode,
    required this.onSearchCep,
    this.isSearchingCep = false,
    this.sectionTitle,
    this.requirePostalCode = true,
  });

  final TextEditingController postalCodeController;
  final TextEditingController addressController;
  final TextEditingController numberController;
  final TextEditingController complementController;
  final TextEditingController neighborhoodController;
  final TextEditingController cityController;
  final TextEditingController stateController;

  final FocusNode? postalCodeFocusNode;
  final FocusNode? addressFocusNode;
  final FocusNode? numberFocusNode;
  final FocusNode? complementFocusNode;
  final FocusNode? neighborhoodFocusNode;
  final FocusNode? cityFocusNode;
  final FocusNode? stateFocusNode;

  final Future<AddressEntity?> Function(String cep) onSearchCep;
  final bool isSearchingCep;
  final String? sectionTitle;
  final bool requirePostalCode;

  @override
  State<AddressFormSection> createState() => _AddressFormSectionState();
}

class _AddressFormSectionState extends State<AddressFormSection> {
  late bool _isAddressLocked;

  @override
  void initState() {
    super.initState();
    _isAddressLocked = false;
  }

  Future<void> _handleCepChanged(String value) async {
    final cleanCep = value.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length == 8) {
      final address = await widget.onSearchCep(cleanCep);
      if (address != null && mounted) {
        widget.addressController.text = address.street;
        widget.neighborhoodController.text = address.neighborhood;
        widget.cityController.text = address.city;
        widget.stateController.text = address.state;

        setState(() {
          _isAddressLocked = true;
        });

        widget.numberFocusNode?.requestFocus();
      }
    } else {
      if (_isAddressLocked) {
        setState(() {
          _isAddressLocked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText.titleMedium(widget.sectionTitle ?? 'Endereço'.hardcoded),
        gapH12,
        BaseTextFormField(
          controller: widget.postalCodeController,
          labelText: widget.requirePostalCode
              ? 'CEP *'.hardcoded
              : 'CEP (Opcional)'.hardcoded,
          hintText: 'Ex: 01001-000'.hardcoded,
          enabled: !widget.isSearchingCep,
          keyboardType: TextInputType.number,
          maxLength: 9,
          focusNode: widget.postalCodeFocusNode,
          textInputAction: TextInputAction.next,
          suffixIcon: widget.isSearchingCep
              ? Padding(
                  padding: const EdgeInsets.all(Sizes.p12),
                  child: LoadingCircle.small(),
                )
              : null,
          validator: widget.requirePostalCode
              ? FormValidators.compose([NonEmptyValidator()])
              : null,
          autovalidateMode: widget.requirePostalCode
              ? AutovalidateMode.onUserInteraction
              : null,
          onChanged: _handleCepChanged,
          onFieldSubmitted: (val) {
            _handleCepChanged(val);
            if (!_isAddressLocked) {
              widget.addressFocusNode?.requestFocus();
            } else {
              widget.numberFocusNode?.requestFocus();
            }
          },
        ),
        gapH12,
        Row(
          children: [
            Expanded(
              flex: 3,
              child: BaseTextFormField(
                controller: widget.addressController,
                labelText: 'Logradouro / Rua'.hardcoded,
                hintText: 'Ex: Avenida Paulista'.hardcoded,
                focusNode: widget.addressFocusNode,
                textInputAction: TextInputAction.next,
                enabled: !_isAddressLocked,
                onFieldSubmitted: (_) => widget.numberFocusNode?.requestFocus(),
              ),
            ),
            gapW12,
            Expanded(
              child: BaseTextFormField(
                controller: widget.numberController,
                labelText: 'Número'.hardcoded,
                hintText: 'Ex: 1000'.hardcoded,
                focusNode: widget.numberFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    widget.complementFocusNode?.requestFocus(),
              ),
            ),
          ],
        ),
        gapH12,
        Row(
          children: [
            Expanded(
              child: BaseTextFormField(
                controller: widget.complementController,
                labelText: 'Complemento (Opcional)'.hardcoded,
                hintText: 'Ex: Bloco A'.hardcoded,
                focusNode: widget.complementFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    widget.neighborhoodFocusNode?.requestFocus(),
              ),
            ),
            gapW12,
            Expanded(
              child: BaseTextFormField(
                controller: widget.neighborhoodController,
                labelText: 'Bairro'.hardcoded,
                hintText: 'Ex: Bela Vista'.hardcoded,
                focusNode: widget.neighborhoodFocusNode,
                textInputAction: TextInputAction.next,
                enabled: !_isAddressLocked,
                onFieldSubmitted: (_) => widget.cityFocusNode?.requestFocus(),
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
                controller: widget.cityController,
                labelText: 'Cidade'.hardcoded,
                hintText: 'Ex: São Paulo'.hardcoded,
                focusNode: widget.cityFocusNode,
                textInputAction: TextInputAction.next,
                enabled: !_isAddressLocked,
                onFieldSubmitted: (_) => widget.stateFocusNode?.requestFocus(),
              ),
            ),
            gapW12,
            Expanded(
              child: BaseTextFormField(
                controller: widget.stateController,
                labelText: 'UF / Estado'.hardcoded,
                hintText: 'Ex: SP'.hardcoded,
                focusNode: widget.stateFocusNode,
                textInputAction: TextInputAction.next,
                enabled: !_isAddressLocked,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
