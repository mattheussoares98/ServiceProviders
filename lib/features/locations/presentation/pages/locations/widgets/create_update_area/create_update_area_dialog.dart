import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/create_update_area/area_name_field.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/create_update_area/description_field.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/create_update_area/floor_field.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uuid/uuid.dart';

class CreateUpdateAreaDialog extends HookWidget {
  const CreateUpdateAreaDialog({
    super.key,
    required this.locationId,
    required this.companyId,
    this.area,
  });

  final String locationId;
  final String companyId;
  final AreaEntity? area;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: area?.name);
    final floorController = useTextEditingController(text: area?.floor);
    final descController = useTextEditingController(text: area?.description);
    final floorFocusNode = useFocusNode();
    final descFocusNode = useFocusNode();
    observeLoading(
      [context.read<LocationsCubit>()],
      statuses: {StateStatus.saving},
    );

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;

      final newArea = AreaEntity(
        id: area?.id ?? const Uuid().v4(),
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

      bool succeeds = false;
      if (area == null) {
        succeeds = await context.read<LocationsCubit>().createArea(newArea);
      } else {
        succeeds = await context.read<LocationsCubit>().updateArea(newArea);
      }
      if (succeeds && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Dialog(
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
                AreaNameField(
                  nameController: nameController,
                  floorFocusNode: floorFocusNode,
                ),
                gapH16,
                FloorField(
                  floorController: floorController,
                  floorFocusNode: floorFocusNode,
                  descFocusNode: descFocusNode,
                ),
                gapH16,
                DescriptionField(
                  descController: descController,
                  descFocusNode: descFocusNode,
                  submit: submit,
                ),
                gapH24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: BaseTextButton(
                        onPressed: Navigator.of(context).pop,
                        text: 'Cancelar'.hardcoded,
                      ),
                    ),
                    gapW16,
                    Flexible(
                      child: PrimaryButton(
                        onTap: submit,
                        text: 'Criar'.hardcoded,
                      ),
                    ),
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
