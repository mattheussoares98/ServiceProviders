import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_location/delete_location_button.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_location/widgets/location_form.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';

@RoutePage()
class CreateUpdateLocationPage extends HookWidget {
  const CreateUpdateLocationPage({super.key, this.existingLocation});
  final LocationEntity? existingLocation;

  @override
  Widget build(BuildContext context) {
    observeRunning([
      ObservedLoadingTarget(
        context.read<LocationsCubit>(),
        sections: const {
          LocationsSections.saveLocation,
          LocationsSections.deleteLocation,
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
      body: LocationForm(
        formKey: formKey,
        existingLocation: existingLocation,
        nameController: nameController,
        cepController: cepController,
        addressController: addressController,
        numberController: numberController,
        complementController: complementController,
        neighborhoodController: neighborhoodController,
        cityController: cityController,
        stateController: stateController,
        cepFocusNode: cepFocusNode,
        addressFocusNode: addressFocusNode,
        numberFocusNode: numberFocusNode,
        complementFocusNode: complementFocusNode,
        neighborhoodFocusNode: neighborhoodFocusNode,
        cityFocusNode: cityFocusNode,
        stateFocusNode: stateFocusNode,
        onSubmit: submit,
      ),
    );
  }
}
