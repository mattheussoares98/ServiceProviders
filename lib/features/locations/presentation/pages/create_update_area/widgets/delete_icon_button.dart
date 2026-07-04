import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteIconButton extends StatelessWidget {
  const DeleteIconButton({super.key, required this.area});
  final AreaEntity? area;

  @override
  Widget build(BuildContext context) {
    if (area == null) {
      return const SizedBox.shrink();
    }
    return BaseIconButton(
      permission: const ActionPermission(
        resource: ResourceType.locations,
        action: PermissionAction.delete,
      ),
      onPressed: () {
        showAlertDialog(
          context: context,
          title: 'Excluir área'.hardcoded,
          onOkPressed: () async {
            final cubit = context.read<LocationsCubit>();
            final succeeds = await cubit.deleteArea(area!.id, area!.locationId);
            if (succeeds && context.mounted) {
              context.router.pop();
            }
          },
          contentText: 'Tem certeza que deseja excluir a área?'.hardcoded,
          defaultActionText: 'Sim'.hardcoded,
          cancelActionText: 'Cancelar'.hardcoded,
        );
      },
      platformIcon: const PlatformIcon(
        materialIcon: Icons.delete,
        cupertinoIcon: CupertinoIcons.trash,
        color: Colors.red,
      ),
    );
  }
}
