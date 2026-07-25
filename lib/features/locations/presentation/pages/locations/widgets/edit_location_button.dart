import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class EditLocationButton extends StatelessWidget {
  const EditLocationButton({super.key, required this.location});
  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      permission: const ActionPermission.resource(
        resource: ResourceType.locations,
        action: PermissionAction.update,
      ),
      onPressed: () {
        context.read<LocationsCubit>().navigateToCreateUpdateLocation(
          existingLocation: location,
        );
      },
      platformIcon: const PlatformIcon(
        cupertinoIcon: CupertinoIcons.pencil,
        materialIcon: Icons.edit,
      ),
    );
  }
}
