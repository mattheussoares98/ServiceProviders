import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class AreaDropdown extends StatelessWidget {
  const AreaDropdown({
    super.key,
    required this.selectedLocationId,
    required this.selectedAreaId,
    required this.onChanged,
  });
  final String? selectedAreaId;
  final String? selectedLocationId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final filteredAreas = context.select<LocationsCubit, List<AreaEntity>>((
      cubit,
    ) {
      return cubit.state.areasByLocation[selectedLocationId] ?? [];
    });
    final areasItems = filteredAreas
        .map(
          (e) => DropdownMenuItem<String>(value: e.id, child: BaseText(e.name)),
        )
        .toList();

    return BaseDropDown<String>(
      key: const ValueKey('Area'),
      label: 'Área *'.hardcoded,
      selectedItem: selectedAreaId,
      hint: selectedLocationId == null
          ? BaseText('Selecione primeiro o local'.hardcoded)
          : (filteredAreas.isEmpty
                ? BaseText('Sem áreas cadastradas'.hardcoded)
                : BaseText('Selecione a área'.hardcoded)),
      validator: (val) => val == null ? 'Selecione uma área'.hardcoded : null,
      items: areasItems,
      onChanged: onChanged,
      showLabelAtTopLeft: selectedAreaId?.isNotEmpty ?? false,
    );
  }
}
