import 'package:flutter/material.dart';

/// Layout breakpoints used in the application.
class Breakpoint {
  static const double desktop = 1024;
  static const double tablet = 600;
}

/// Reusable widget for showing a child with a maximum content width constraint.
/// If available width is larger than the maximum width, the child will be centered.
/// If available width is smaller than the maximum width, the child uses all available width.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    this.maxContentWidth = Breakpoint.desktop,
    this.padding = EdgeInsets.zero,
    required this.child,
    this.isSliver = false,
  });

  final double maxContentWidth;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final bool isSliver;

  @override
  Widget build(BuildContext context) {
    final widget = Center(
      child: SizedBox(
        width: maxContentWidth,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (isSliver) {
      return SliverToBoxAdapter(child: widget);
    }
    return widget;
  }
}
