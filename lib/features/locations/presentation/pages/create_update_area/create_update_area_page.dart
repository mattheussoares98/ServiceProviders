import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_area/widgets/area_name_field.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_area/widgets/delete_icon_button.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_area/widgets/description_field.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/pages/create_update_area/widgets/floor_field.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class CreateUpdateAreaPage extends HookWidget {
  const CreateUpdateAreaPage({
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
      statuses: {StateStatus.saving, StateStatus.deleting},
    );

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;

      final succeeds = await context.read<LocationsCubit>().saveArea(
        id: area?.id,
        locationId: locationId,
        companyId: companyId,
        name: nameController.text,
        floor: floorController.text,
        description: descController.text,
        createdAt: area?.createdAt,
      );

      if (succeeds && context.mounted) {
        context.read<LocationsCubit>().popRoute();
      }
    }

    return BaseScaffold(
      appBar: BaseAppBar(
        title: area == null
            ? 'Criando nova área'.hardcoded
            : 'Editando área'.hardcoded,
        actions: [DeleteIconButton(area: area)],
      ),
      body: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            gapH32,
            BlocSelector<LocationsCubit, LocationsState, bool>(
              selector: (state) => state.status == StateStatus.saving,
              builder: (_, loading) {
                return PrimaryButton(
                  onTap: submit,
                  text: area == null ? 'Criar'.hardcoded : 'Salvar'.hardcoded,
                  isLoading: loading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
