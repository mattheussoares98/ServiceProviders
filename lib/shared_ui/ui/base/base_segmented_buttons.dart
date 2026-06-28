import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseSegmentedButtons<T> extends StatelessWidget {
  const BaseSegmentedButtons({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.itemColorBuilder,
  });

  final List<T> items;
  final T? selectedValue;
  // The ValueChanged callback accepts a generic parameter T, which triggers
  // the unsafe_variance check in newer Dart releases. We ignore this safely here
  // as the callback only propagates selections upwards.
  // ignore: unsafe_variance
  final ValueChanged<T>? onChanged;
  final String Function(T) itemLabelBuilder;
  final Color? Function(T)? itemColorBuilder;

  @override
  Widget build(BuildContext context) {
    // Find the index of the selected value
    final selectedIndex = items.indexOf(selectedValue as T);
    final fallbackIndex = items.isNotEmpty ? 0 : -1;
    final activeIndex = selectedIndex != -1 ? selectedIndex : fallbackIndex;

    final selectedColor = activeIndex != -1
        ? itemColorBuilder?.call(items[activeIndex])
        : null;

    return IgnorePointer(
      ignoring: onChanged == null,
      child: CupertinoSlidingSegmentedControl<int>(
        groupValue: activeIndex != -1 ? activeIndex : null,
        onValueChanged: (index) {
          if (index != null && index >= 0 && index < items.length) {
            onChanged?.call(items[index]);
          }
        },
        thumbColor: selectedColor ?? context.theme.primaryColor,
        children: {
          for (int i = 0; i < items.length; i++)
            i: Padding(
              padding: const EdgeInsets.all(Sizes.p8),
              child: FittedBox(
                child: Text(
                  itemLabelBuilder(items[i]),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: activeIndex == i
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
