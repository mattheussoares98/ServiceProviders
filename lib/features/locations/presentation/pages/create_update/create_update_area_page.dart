import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/pages/create_update/widgets/area_name_field.dart';
import 'package:clean_architecture/features/locations/presentation/pages/create_update/widgets/description_field.dart';
import 'package:clean_architecture/features/locations/presentation/pages/create_update/widgets/floor_field.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

@RoutePage()
class CreateUpdateAreaPage extends StatelessWidget {
  const CreateUpdateAreaPage({
    super.key,
    required this.locationsCubit,
    required this.locationId,
    required this.companyId,
    this.area,
  });

  final LocationsCubit locationsCubit;
  final String locationId;
  final String companyId;
  final AreaEntity? area;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locationsCubit,
      child: _Body(locationId: locationId, companyId: companyId, area: area),
    );
  }
}

class _Body extends HookWidget {
  const _Body({required this.locationId, required this.companyId, this.area});

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

    final status = context.select<LocationsCubit, StateStatus>(
      (cubit) => cubit.state.status,
    );

    final isSubmitting =
        status == StateStatus.saving || status == StateStatus.deleting;

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
        context.router.pop();
      }
    }

    return BaseScaffold(
      appBar: BaseAppBar(
        title: area == null
            ? 'Criando nova área'.hardcoded
            : 'Editando área'.hardcoded,
        actions: [
          if (area != null)
            BaseIconButton(
              permission: const ActionPermission(
                resource: ResourceType.locations,
                action: PermissionAction.delete,
              ),
              onPressed: isSubmitting
                  ? null
                  : () {
                      showAlertDialog(
                        context: context,
                        title: 'Excluir área'.hardcoded,
                        onOkPressed: () async {
                          final cubit = context.read<LocationsCubit>();
                          await cubit.deleteArea(area!.id, area!.locationId);
                          if (cubit.state.status != StateStatus.deletingError &&
                              context.mounted) {
                            context.router.pop();
                          }
                        },
                        contentText:
                            'Tem certeza que deseja excluir a área?'.hardcoded,
                        defaultActionText: 'Sim'.hardcoded,
                        cancelActionText: 'Cancelar'.hardcoded,
                      );
                    },
              platformIcon: const PlatformIcon(
                materialIcon: Icons.delete,
                cupertinoIcon: CupertinoIcons.trash,
                color: Colors.red,
              ),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p16),
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
              PrimaryButton(
                onTap: submit,
                text: area == null ? 'Criar'.hardcoded : 'Salvar'.hardcoded,
                isLoading: status == StateStatus.saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
