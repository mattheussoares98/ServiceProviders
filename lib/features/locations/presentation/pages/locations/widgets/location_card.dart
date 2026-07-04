import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/add_area_button.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/area_item.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/delete_location_button.dart';
import 'package:clean_architecture/features/locations/presentation/pages/locations/widgets/edit_location_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';

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
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Center(child: BaseText.titleMedium(location.name)),
        subtitle: addressText.isNotEmpty ? BaseText(addressText) : null,
        trailing: FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: EditLocationButton(location: location)),
              Flexible(child: DeleteLocationButton(location: location)),
            ],
          ),
        ),

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
                ...areas.map(
                  (area) => AreaItem(area: area, location: location),
                ),
              gapH16,
              Align(
                alignment: Alignment.centerRight,
                child: FittedBox(child: AddAreaButton(location: location)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
