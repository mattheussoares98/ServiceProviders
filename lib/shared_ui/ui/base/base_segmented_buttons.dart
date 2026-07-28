import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

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
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    if (items.length == 1) {
      final singleItem = items.first;
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.p16,
          vertical: Sizes.p8,
        ),
        decoration: BoxDecoration(
          color:
              itemColorBuilder?.call(singleItem) ?? context.theme.primaryColor,
          borderRadius: BorderRadius.circular(Sizes.p8),
        ),
        child: BaseText(itemLabelBuilder(singleItem), color: Colors.white),
      );
    }

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
                child: BaseText(
                  itemLabelBuilder(items[i]),
                  overflow: TextOverflow.ellipsis,
                  color: activeIndex == i
                      ? Colors.white
                      : context.theme.colorScheme.onSurface,
                ),
              ),
            ),
        },
      ),
    );
  }
}
