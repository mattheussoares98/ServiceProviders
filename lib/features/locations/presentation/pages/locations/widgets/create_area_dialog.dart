import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
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

class CreateAreaDialog extends HookWidget {
  const CreateAreaDialog({
    super.key,
    required this.locationId,
    required this.companyId,
  });

  final String locationId;
  final String companyId;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController();
    final floorController = useTextEditingController();
    final descController = useTextEditingController();
    final floorFocusNode = useFocusNode();
    final descFocusNode = useFocusNode();

    void submit() {
      if (formKey.currentState?.validate() != true) return;

      final area = AreaEntity(
        id: const Uuid().v4(),
        locationId: locationId,
        companyId: companyId,
        name: nameController.text.trim(),
        floor: floorController.text.trim().isEmpty
            ? null
            : floorController.text.trim(),
        description: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Navigator.of(context).pop();
      context.read<LocationsCubit>().createArea(area);
    }

    return Dialog(
      //TODO add option to delete the Area
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BaseText.titleMedium(
                  'Criar Nova Área'.hardcoded,
                  textAlign: TextAlign.center,
                ),
                gapH16,
                BaseTextFormField(
                  labelText: 'Nome da Área *'.hardcoded,
                  hintText: 'Ex: Sala de Reunião'.hardcoded,
                  controller: nameController,
                  onFieldSubmitted: (_) => floorFocusNode.requestFocus(),
                  validator: FormValidators.compose([NonEmptyValidator()]),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                ),
                gapH16,
                BaseTextFormField(
                  labelText: 'Andar / Piso (Opcional)'.hardcoded,
                  hintText: 'Ex: 2º Andar'.hardcoded,
                  controller: floorController,
                  focusNode: floorFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => descFocusNode.requestFocus(),
                ),
                gapH16,
                BaseTextFormField(
                  labelText: 'Descrição (Opcional)'.hardcoded,
                  hintText: 'Ex: Sala de reuniões principal'.hardcoded,
                  controller: descController,
                  focusNode: descFocusNode,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => submit(),
                ),
                gapH24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BaseTextButton(
                      onPressed: Navigator.of(context).pop,
                      text: 'Cancelar'.hardcoded,
                    ),
                    gapW16,
                    PrimaryButton(onTap: submit, text: 'Criar'.hardcoded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
