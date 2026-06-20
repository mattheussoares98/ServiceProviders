import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationDropdown extends StatelessWidget {
  const LocationDropdown({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });
  final String? selectedId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final items = context.select(
      (LocationsCubit cubit) => cubit.state.locations.map(
        (e) => DropdownMenuItem(value: e.id, child: BaseText(e.name)),
      ),
    );

    return BaseDropDown<String>(
      key: const ValueKey('Location'),
      showLabelAtTopLeft: true,
      label: 'Local *'.hardcoded,
      selectedItem: selectedId,
      validator: (val) => val == null ? 'Selecione um local'.hardcoded : null,
      items: items.toList(),
      onChanged: onChanged,
    );
  }
}
