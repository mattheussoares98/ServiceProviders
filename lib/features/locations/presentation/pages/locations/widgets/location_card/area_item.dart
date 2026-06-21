import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/create_area/create_area_dialog.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    final deletingLocation = context.select<LocationsCubit, bool>(
      (cubit) => cubit.state.deletingIds.contains(location.id),
      //* don't need to treat the updating too because it is updated in another page.
      //* So, there is treating the loading
    );

    return Row(
      children: [
        const PlatformIcon(
          materialIcon: Icons.room,
          cupertinoIcon: CupertinoIcons.location,
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              BaseText.titleMedium(area.name),
              gapH4,
              BaseText.bodySmall(areaSubtitle),
            ],
          ),
        ),
        BaseIconButton(
          onPressed: deletingLocation
              ? null
              : () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<LocationsCubit>(),
                      child: CreateAreaDialog(
                        locationId: location.id,
                        companyId: location.companyId,
                        area: area,
                      ),
                    ),
                  );
                },
          platformIcon: const PlatformIcon(
            materialIcon: Icons.edit,
            cupertinoIcon: CupertinoIcons.pencil,
            isSmall: true,
          ),
        ),
        BaseIconButton(
          onPressed: deletingLocation
              ? null
              : () {
                  showAlertDialog(
                    context: context,
                    title: 'Excluir área'.hardcoded,
                    onOkPressed: () => context
                        .read<LocationsCubit>()
                        .deleteArea(area.id, area.locationId),
                    contentText:
                        'Tem certeza que deseja excluir a área?'.hardcoded,
                    defaultActionText: 'Sim'.hardcoded,
                    cancelActionText: 'Cancelar'.hardcoded,
                  );
                },
          platformIcon: const PlatformIcon(
            materialIcon: Icons.delete_outline,
            cupertinoIcon: CupertinoIcons.trash,
            color: Colors.red,
            isSmall: true,
          ),
        ),
      ],
    );
  }
}
