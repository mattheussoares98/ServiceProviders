import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_location/delete_location_button.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

@RoutePage()
class CreateUpdateLocationPage extends HookWidget {
  const CreateUpdateLocationPage({super.key, this.existingLocation});
  final LocationEntity? existingLocation;

  @override
  Widget build(BuildContext context) {
    observeLoading([
      ObservedLoadingTarget(
        context.read<LocationsCubit>(),
        sections: const {
          LocationsSections.saveLocation: {SectionStatus.running},
          LocationsSections.deleteLocation: {SectionStatus.running},
        },
      ),
    ]);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(
      text: existingLocation?.name,
    );
    final cepController = useTextEditingController(
      text: existingLocation?.postalCode,
    );
    final addressController = useTextEditingController(
      text: existingLocation?.address,
    );
    final numberController = useTextEditingController(
      text: existingLocation?.number,
    );
    final complementController = useTextEditingController(
      text: existingLocation?.complement,
    );
    final neighborhoodController = useTextEditingController(
      text: existingLocation?.neighborhood,
    );
    final cityController = useTextEditingController(
      text: existingLocation?.city,
    );
    final stateController = useTextEditingController(
      text: existingLocation?.state,
    );
    final cepFocusNode = useFocusNode();
    final addressFocusNode = useFocusNode();
    final numberFocusNode = useFocusNode();
    final complementFocusNode = useFocusNode();
    final neighborhoodFocusNode = useFocusNode();
    final cityFocusNode = useFocusNode();
    final stateFocusNode = useFocusNode();

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;

      final succeeds = await context.read<LocationsCubit>().saveLocation(
        id: existingLocation?.id,
        name: nameController.text,
        postalCode: cepController.text,
        address: addressController.text,
        number: numberController.text,
        complement: complementController.text,
        neighborhood: neighborhoodController.text,
        city: cityController.text,
        addressState: stateController.text,
        createdAt: existingLocation?.createdAt,
      );

      if (succeeds && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return BaseScaffold(
      appBar: BaseAppBar(
        title: existingLocation == null
            ? 'Criando local'.hardcoded
            : 'Editando local'.hardcoded,
        actions: [DeleteLocationButton(locationId: existingLocation?.id)],
      ),
      body: Form(
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
              BaseTextFormField(
                labelText: 'CEP (Opcional)'.hardcoded,
                hintText: 'Ex: 01001-000'.hardcoded,
                controller: cepController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                focusNode: cepFocusNode,
                onFieldSubmitted: (_) => addressFocusNode.requestFocus(),
              ),
              gapH16,
              BaseTextFormField(
                labelText: 'Endereço (Opcional)'.hardcoded,
                hintText: 'Ex: Avenida Paulista'.hardcoded,
                controller: addressController,
                textInputAction: TextInputAction.next,
                focusNode: addressFocusNode,
                onFieldSubmitted: (_) => numberFocusNode.requestFocus(),
              ),
              gapH16,
              Row(
                children: [
                  Expanded(
                    child: BaseTextFormField(
                      labelText: 'Número (Opcional)'.hardcoded,
                      hintText: 'Ex: 1000'.hardcoded,
                      controller: numberController,
                      textInputAction: TextInputAction.next,
                      focusNode: numberFocusNode,
                      onFieldSubmitted: (_) =>
                          complementFocusNode.requestFocus(),
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: BaseTextFormField(
                      labelText: 'Complemento (Opcional)'.hardcoded,
                      hintText: 'Ex: Bloco A'.hardcoded,
                      controller: complementController,
                      textInputAction: TextInputAction.next,
                      focusNode: complementFocusNode,
                      onFieldSubmitted: (_) =>
                          neighborhoodFocusNode.requestFocus(),
                    ),
                  ),
                ],
              ),
              gapH16,
              BaseTextFormField(
                labelText: 'Bairro (Opcional)'.hardcoded,
                hintText: 'Ex: Bela Vista'.hardcoded,
                controller: neighborhoodController,
                textInputAction: TextInputAction.next,
                focusNode: neighborhoodFocusNode,
                onFieldSubmitted: (_) => cityFocusNode.requestFocus(),
              ),
              gapH16,
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: BaseTextFormField(
                      labelText: 'Cidade (Opcional)'.hardcoded,
                      hintText: 'Ex: São Paulo'.hardcoded,
                      controller: cityController,
                      textInputAction: TextInputAction.next,
                      focusNode: cityFocusNode,
                      onFieldSubmitted: (_) => stateFocusNode.requestFocus(),
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: BaseTextFormField(
                      labelText: 'UF (Opcional)'.hardcoded,
                      hintText: 'Ex: SP'.hardcoded,
                      controller: stateController,
                      textInputAction: TextInputAction.done,
                      focusNode: stateFocusNode,
                      onFieldSubmitted: (_) => submit(),
                    ),
                  ),
                ],
              ),
              gapH24,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: BaseTextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      text: 'Cancelar'.hardcoded,
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: BaseButton(
                      onTap: submit,
                      width: Sizes.p120,
                      text: 'Salvar'.hardcoded,
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
