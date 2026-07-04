import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditLocationButton extends StatelessWidget {
  const EditLocationButton({super.key, required this.location});
  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      permission: const ActionPermission(
        resource: ResourceType.locations,
        action: PermissionAction.update,
      ),
      onPressed: () {
        context.router.push(
          CreateUpdateLocationRoute(existingLocation: location),
        );
      },
      platformIcon: const PlatformIcon(
        cupertinoIcon: CupertinoIcons.pencil,
        materialIcon: Icons.edit,
      ),
    );
  }
}
