import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/create_area_dialog.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({super.key, required this.location, required this.areas});

  final LocationEntity location;
  final List<AreaEntity> areas;

  @override
  Widget build(BuildContext context) {
    final addressText = [
      if (location.address?.isNotEmpty ?? false) location.address,
      if (location.number?.isNotEmpty ?? false) location.number,
      if (location.neighborhood?.isNotEmpty ?? false) location.neighborhood,
      if (location.city?.isNotEmpty ?? false) location.city,
      if (location.state?.isNotEmpty ?? false) location.state,
    ].join(', ');

    return Card(
      //TODO add option to delete the Location
      child: ExpansionTile(
        title: Center(child: BaseText.titleMedium(location.name)),
        subtitle: addressText.isNotEmpty ? BaseText(addressText) : null,
        children: [
          Column(
            children: [
              if (areas.isEmpty)
                Center(
                  child: BaseText.bodyMedium(
                    'Nenhuma área cadastrada'.hardcoded,
                  ),
                )
              else
                ...areas.map((area) {
                  final areaSubtitle = [
                    if (area.floor?.isNotEmpty ?? false) area.floor,
                    if (area.description?.isNotEmpty ?? false) area.description,
                  ].join(' - ');

                  return BaseListTile(
                    title: area.name,
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.room,
                      cupertinoIcon: CupertinoIcons.location,
                    ),
                    subtitle: areaSubtitle.isNotEmpty ? areaSubtitle : null,
                    padding: EdgeInsets.zero,
                  );
                }),
              gapH16,
              Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  child: BaseTextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: context.read<LocationsCubit>(),
                          child: CreateAreaDialog(
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
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
