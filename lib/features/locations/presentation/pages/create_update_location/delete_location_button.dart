import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class DeleteLocationButton extends StatelessWidget {
  const DeleteLocationButton({super.key, required this.locationId});
  final String? locationId;

  @override
  Widget build(BuildContext context) {
    if (locationId == null) return const SizedBox.shrink();

    return BaseIconButton(
      permission: const ActionPermission.resource(
        resourceType: ResourceType.locations,
        permissionAction: PermissionAction.delete,
      ),
      isLoading: context.select<LocationsCubit, bool>(
        (cubit) =>
            cubit.state.sections[LocationsSections.deleteLocation] ==
            const SectionState.running(),
      ),
      onPressed: () {
        showAlertDialog(
          context: context,
          title: 'Excluir local?'.hardcoded,
          onOkPressed: () =>
              context.read<LocationsCubit>().deleteLocation(locationId!),
          contentText: 'Tem certeza que deseja excluir o local?'.hardcoded,
          defaultActionText: 'Sim'.hardcoded,
          cancelActionText: 'Cancelar'.hardcoded,
        );
      },
      platformIcon: const PlatformIcon(
        cupertinoIcon: CupertinoIcons.trash,
        materialIcon: Icons.delete,
        color: Colors.red,
      ),
    );
  }
}
