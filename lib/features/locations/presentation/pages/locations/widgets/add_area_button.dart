import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class AddAreaButton extends StatelessWidget {
  const AddAreaButton({super.key, required this.location});
  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<LocationsCubit, bool>(
      (cubit) =>
          cubit.state.section(BaseSections.load).isRunning ||
          cubit.state.section(LocationsSections.deleteLocation).isRunning,
    );

    return BaseTextButton(
      permission: const ActionPermission.resource(
        resourceType: ResourceType.locations,
        permissionAction: PermissionAction.create,
      ),
      onPressed: isLoading
          ? null
          : () {
              context.read<LocationsCubit>().navigateToCreateUpdateArea(
                locationId: location.id,
              );
            },
      platformIcon: const PlatformIcon(
        materialIcon: Icons.add,
        cupertinoIcon: CupertinoIcons.add,
      ),
      text: 'Adicionar área'.hardcoded,
    );
  }
}
