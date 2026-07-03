import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/create_update_area/create_update_area_dialog.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddAreaButton extends StatelessWidget {
  const AddAreaButton({super.key, required this.location});
  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<LocationsCubit, bool>(
      (cubit) =>
          cubit.state.status == StateStatus.loading ||
          cubit.state.status == StateStatus.deleting,
    );

    return BaseTextButton(
      permission: const ActionPermission(
        resource: ResourceType.locations,
        action: PermissionAction.create,
      ),
      onPressed: isLoading
          ? null
          : () {
              showDialog<void>(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<LocationsCubit>(),
                  child: CreateUpdateAreaDialog(
                    locationId: location.id,
                    companyId: location.companyId,
                  ),
                ),
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
