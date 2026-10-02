import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/address_form_section.dart';

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
    this.addressFocusNode,
    this.numberFocusNode,
    this.complementFocusNode,
    this.neighborhoodFocusNode,
    this.cityFocusNode,
    this.stateFocusNode,
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

  @override
  Widget build(BuildContext context) {
    final isSearchingCep = context.select<CustomersCubit, bool>(
      (c) =>
          c.state.sections[CustomersSections.loadAddressByCep] ==
          const SectionState.running(),
    );

    return AddressFormSection(
      requirePostalCode: false,
      postalCodeController: postalCodeController,
      addressController: addressController,
      numberController: numberController,
      complementController: complementController,
      neighborhoodController: neighborhoodController,
      cityController: cityController,
      stateController: stateController,
      postalCodeFocusNode: postalCodeFocusNode,
      addressFocusNode: addressFocusNode,
      numberFocusNode: numberFocusNode,
      complementFocusNode: complementFocusNode,
      neighborhoodFocusNode: neighborhoodFocusNode,
      cityFocusNode: cityFocusNode,
      stateFocusNode: stateFocusNode,
      isSearchingCep: isSearchingCep,
      onSearchCep: (cep) => context.read<CustomersCubit>().getAddressByCep(cep),
    );
  }
}
