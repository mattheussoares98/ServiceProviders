import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/domain/entities/selectable_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

/// PERFORMANCE: This widget chooses between a Segmented Control and a Wrap
/// layout based on available width to prevent text overflow and unreadable labels.
class DefaultChoiceChip<T extends SelectableItem<T>> extends StatelessWidget {
  const DefaultChoiceChip({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.allowNullSelection = false,
  });
  final List<T> items;
  final T? selectedValue;
  //error because of the dart version
  // ignore: unsafe_variance
  final ValueChanged<T> onChanged;
  final bool allowNullSelection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Wrap(
        key: const ValueKey('wrap'),
        spacing: Sizes.p8,
        runSpacing: Sizes.p8,
        alignment: WrapAlignment.center,
        children: items.map((item) {
          final isSelected = item.value == selectedValue;
          return ChoiceChip(
            key: ValueKey(item),
            label: BaseText(item.name),
            selected: isSelected,
            onSelected: (selected) {
              if (allowNullSelection) {
                onChanged(item.value);
              } else if (selected) {
                onChanged(item.value);
              }
            },
            selectedColor: item.color ?? theme.colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
          );
        }).toList(),
      ),
    );
  }
}
