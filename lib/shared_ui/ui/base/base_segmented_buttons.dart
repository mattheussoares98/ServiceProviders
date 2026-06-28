import 'package:clean_architecture/core/domain/entities/selectable_item.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseSegmentedButtons<T extends Object> extends StatelessWidget {
  const BaseSegmentedButtons({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<SelectableItem<T>>
  items; //TODO change how should pass the parameter
  final T? selectedValue;
  // The ValueChanged callback accepts a generic parameter T, which triggers
  // the unsafe_variance check in newer Dart releases. We ignore this safely here
  // as the callback only propagates selections upwards.
  // ignore: unsafe_variance
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    // Find the item matching selectedValue or default to the first item
    final selectedItem = items.firstWhere(
      (item) => item.value == selectedValue,
      orElse: () => items.first,
    );

    return IgnorePointer(
      ignoring: onChanged == null,
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: selectedValue,
        onValueChanged: (value) {
          if (value != null) {
            onChanged?.call(value);
          }
        },
        thumbColor: selectedItem.color ?? context.theme.primaryColor,
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
                        : context.theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
        },
      ),
    );
  }
}
