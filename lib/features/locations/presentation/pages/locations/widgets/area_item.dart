import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class AreaItem extends StatelessWidget {
  const AreaItem({super.key, required this.area, required this.location});
  final AreaEntity area;
  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final areaSubtitle = [
      if (area.floor?.isNotEmpty ?? false) area.floor,
      if (area.description?.isNotEmpty ?? false) area.description,
    ].join(' - ');

    return Row(
      children: [
        if (ScreenUtil.I.width > 200) ...[
          const PlatformIcon(
            materialIcon: Icons.room,
            cupertinoIcon: CupertinoIcons.location,
          ),
          gapW12,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BaseText.titleMedium(area.name),
              gapH4,
              BaseText.bodySmall(areaSubtitle),
            ],
          ),
        ),
        FittedBox(
          child: BaseIconButton(
            permission: const ActionPermission.resource(
              resource: ResourceType.locations,
              action: PermissionAction.update,
            ),
            onPressed: () {
              context.read<LocationsCubit>().navigateToCreateUpdateArea(
                locationId: location.id,
                companyId: location.companyId,
                area: area,
              );
            },
            platformIcon: const PlatformIcon(
              materialIcon: Icons.edit,
              cupertinoIcon: CupertinoIcons.pencil,
              isSmall: true,
            ),
          ),
        ),
      ],
    );
  }
}
