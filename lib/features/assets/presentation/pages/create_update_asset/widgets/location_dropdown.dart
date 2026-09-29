import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class LocationDropdown extends StatelessWidget {
  const LocationDropdown({
    super.key,
    required this.selectedLocationId,
    required this.onChangeArea,
    required this.onChangeLocation,
    this.isRequired = true,
  });
  final String? selectedLocationId;
  final ValueChanged<String?> onChangeArea;
  final ValueChanged<String?> onChangeLocation;
  final bool isRequired;

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
      label: isRequired ? 'Local *'.hardcoded : 'Local (opcional)'.hardcoded,
      selectedItem: selectedLocationId,
      validator: isRequired
          ? (val) => val == null ? 'Selecione um local'.hardcoded : null
          : null,
      items: locationDropdownItems,
      onChanged: (val) {
        onChangeLocation(val);
        onChangeArea(null);
      },
      onClear: !isRequired && selectedLocationId != null
          ? () {
              onChangeLocation(null);
              onChangeArea(null);
            }
          : null,
      showLabelAtTopLeft: selectedLocationId?.isNotEmpty ?? false,
    );
  }
}
