import 'package:clean_architecture/core/domain/entities/selectable_item.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';

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
            label: Text(item.name),
            selected: isSelected,
            onSelected: (selected) {
              if (allowNullSelection) {
                onChanged(item.value);
              } else if (selected) {
                onChanged(item.value);
              }
            },
            selectedColor: item.color ?? theme.primaryColor,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : theme.textTheme.bodyMedium?.color,
              fontSize: 12,
            ),
          );
        }).toList(),
      ),
    );
  }
}
