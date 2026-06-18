import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/session/session_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/validators/form_validators.dart';
import 'package:clean_architecture/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uuid/uuid.dart';

class CreateLocation extends HookWidget {
  const CreateLocation({super.key, this.existingLocation});
  final LocationEntity? existingLocation;

  @override
  Widget build(BuildContext context) {
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

      final companyId = context.read<SessionCubit>().state.user.companyId;
      final now = DateTime.now();

      //TODO Add ViaCep methods to load the addresses
      final location = LocationEntity(
        id: existingLocation?.id ?? const Uuid().v4(), //TODO move it to cubit
        companyId: companyId,
        name: nameController.text.trim(),
        postalCode:
            cepController.text
                .trim()
                .isEmpty //TODO treat all of it in the Cubit
            ? null
            : cepController.text.trim(),
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        number: numberController.text.trim().isEmpty
            ? null
            : numberController.text.trim(),
        complement: complementController.text.trim().isEmpty
            ? null
            : complementController.text.trim(),
        neighborhood: neighborhoodController.text.trim().isEmpty
            ? null
            : neighborhoodController.text.trim(),
        city: cityController.text.trim().isEmpty
            ? null
            : cityController.text.trim(),
        state: stateController.text.trim().isEmpty
            ? null
            : stateController.text.trim(),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      bool succeeds;

      if (existingLocation == null) {
        succeeds = await context.read<LocationsCubit>().createLocation(
          location,
        );
      } else {
        succeeds = await context.read<LocationsCubit>().updateLocation(
          location,
        );
      }
      if (succeeds && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Padding(
      padding: const EdgeInsets.all(Sizes.p16),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BaseText.titleMedium(
                'Criar Novo Local'.hardcoded,
                textAlign: TextAlign.center,
              ),
              gapH16,
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BaseTextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Cancelar'.hardcoded,
                  ),
                  gapW64,
                  PrimaryButton(
                    onTap: submit,
                    width: Sizes.p120,
                    text: existingLocation == null
                        ? 'Criar'.hardcoded
                        : 'Alterar'.hardcoded,
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
