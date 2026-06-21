import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationDropdown extends StatelessWidget {
  const LocationDropdown({
    super.key,
    required this.selectedLocationId,
    required this.onChangeArea,
    required this.onChangeLocation,
  });
  final String? selectedLocationId;
  final ValueChanged<String?> onChangeArea;
  final ValueChanged<String?> onChangeLocation;
  @override
  Widget build(BuildContext context) {
    final locations = context.select<LocationsCubit, List<LocationEntity>>(
      (cubit) => cubit.state.locations,
    );
    final locationDropdownItems = locations.map((l) {
      return DropdownMenuItem<String>(value: l.id, child: BaseText(l.name));
    }).toList();

    return BaseDropDown<String>(
      key: const ValueKey('Location'),
      label: 'Local *'.hardcoded,
      selectedItem: selectedLocationId,
      validator: (val) => val == null ? 'Selecione um local'.hardcoded : null,
      items: locationDropdownItems,
      onChanged: (val) {
        onChangeLocation(val);
        onChangeArea(null);
      },
      showLabelAtTopLeft: selectedLocationId?.isNotEmpty ?? false,
    );
  }
}
