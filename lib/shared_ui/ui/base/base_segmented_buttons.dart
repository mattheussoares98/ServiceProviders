import 'package:clean_architecture/core/domain/entities/selectable_item.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefaultSegmentedButtons<T extends Object> extends StatelessWidget {
  const DefaultSegmentedButtons({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<SelectableItem<T>> items;
  final T? selectedValue;
  // The ValueChanged callback accepts a generic parameter T, which triggers
  // the unsafe_variance check in newer Dart releases. We ignore this safely here
  // as the callback only propagates selections upwards.
  // ignore: unsafe_variance
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Find the item matching selectedValue or default to the first item
    final selectedItem = items.firstWhere(
      (item) => item.value == selectedValue,
      orElse: () => items.first,
    );

    return CupertinoSlidingSegmentedControl<T>(
      groupValue: selectedValue,
      onValueChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
      thumbColor: selectedItem.color ?? theme.primaryColor,
      children: {
        for (final item in items)
          item.value: Padding(
            padding: const EdgeInsets.all(Sizes.p8),
            child: FittedBox(
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selectedValue == item.value
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
      },
    );
  }
}
