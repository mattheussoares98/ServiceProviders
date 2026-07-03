import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/create_update_area/create_location.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditLocationButton extends StatelessWidget {
  const EditLocationButton({super.key, required this.location});
  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final isDeleting = context.select<LocationsCubit, bool>(
      (cubit) => cubit.state.deletingIds.contains(location.id),
    );
    return BaseIconButton(
      permission: const ActionPermission(
        resource: ResourceType.locations,
        action: PermissionAction.update,
      ),
      onPressed: isDeleting
          ? null
          : () {
              showModalPage<void>(
                BlocProvider.value(
                  value: context.read<LocationsCubit>(),
                  child: CreateLocation(existingLocation: location),
                ),
                context,
              );
            },
      platformIcon: const PlatformIcon(
        cupertinoIcon: CupertinoIcons.pencil,
        materialIcon: Icons.edit,
      ),
    );
  }
}
