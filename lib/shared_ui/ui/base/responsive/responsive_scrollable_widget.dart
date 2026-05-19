import 'package:clean_architecture/shared_ui/ui/base/responsive/responsive_center.dart';
import 'package:flutter/material.dart';

/// Scrollable widget that shows a responsive card with a given child widget.
/// Useful for displaying forms and other widgets that need to be scrollable.
class ResponsiveScrollableWidget extends StatelessWidget {
  const ResponsiveScrollableWidget({
    super.key,
    required this.child,
    this.centralize = false,
    this.maxContentWidth = Breakpoint.desktop,
    this.isSliverPage = false,
    this.padding,
    this.scrollPhysics,
  });

  final Widget child;
  final bool centralize;
  final double maxContentWidth;
  final bool isSliverPage;
  final EdgeInsets? padding;
  final ScrollPhysics? scrollPhysics;

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);

    final widget = SizedBox(
      height: centralize ? mediaSize.height : null,
      width: centralize ? mediaSize.width : null,
      child: ResponsiveCenter(maxContentWidth: maxContentWidth, child: child),
    );

    if (isSliverPage) {
      return widget;
    }

    return SingleChildScrollView(child: widget);
  }
}
