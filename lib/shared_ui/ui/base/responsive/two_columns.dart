import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_center.dart';

/// A layout widget that splits its content into two columns on wide screens (>= [breakpoint])
/// and stacks them vertically on narrow screens. It also centers itself and constrains
/// its maximum width to [maxWidth] (default 1500).
class TwoColumns extends StatelessWidget {
  const TwoColumns({
    super.key,
    required this.firstColumn,
    required this.secondColumn,
    this.breakpoint = 1000.0,
    this.spacing = 16.0,
    this.maxWidth = 1500.0,
  });

  /// The widgets to display in the first (left) column.
  final List<Widget> firstColumn;

  /// The widgets to display in the second (right) column.
  final List<Widget> secondColumn;

  /// The width breakpoint below which the layout switches to a single vertical column.
  final double breakpoint;

  /// The horizontal and vertical spacing between columns and stacks.
  final double spacing;

  /// The maximum content width of the layout.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final oneColumnWidgets = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...firstColumn,
        SizedBox(height: spacing),
        ...secondColumn,
      ],
    );
    if (PlatformUtil.isMobile) {
      return oneColumnWidgets;
    }
    return ResponsiveCenter(
      maxContentWidth: maxWidth,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= breakpoint;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: firstColumn,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: secondColumn,
                  ),
                ),
              ],
            );
          }

          return oneColumnWidgets;
        },
      ),
    );
  }
}
