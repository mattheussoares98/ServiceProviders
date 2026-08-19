import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_center.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class ResponsiveListFlow extends StatelessWidget {
  const ResponsiveListFlow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.maxItemWidth = 380,
    this.isSliver = false,
    this.padding,
    this.physics,
    this.useMultiColumnWhenMobile = false,
    this.scrollController,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double? maxItemWidth;
  final bool isSliver;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool useMultiColumnWhenMobile;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.only(bottom: Sizes.p48);

    if (PlatformUtil.isMobile && !useMultiColumnWhenMobile) {
      if (isSliver) {
        return SliverPadding(
          padding: effectivePadding,
          sliver: SliverList.builder(
            itemBuilder: itemBuilder,
            itemCount: itemCount,
          ),
        );
      }
      return ListView.builder(
        controller: scrollController,
        physics: physics,
        padding: effectivePadding,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      );
    }

    final maxWidthSize = ScreenType.desktop.maxWidth;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = min(maxWidthSize, screenWidth);
    final effectiveItemWidth = maxItemWidth ?? 380.0;
    final itemsPerRow = max((width / effectiveItemWidth).floor(), 1);

    if (isSliver) {
      final grid = SliverMasonryGrid.count(
        crossAxisCount: itemsPerRow,
        mainAxisSpacing: Sizes.p8,
        crossAxisSpacing: Sizes.p8,
        childCount: itemCount,
        itemBuilder: itemBuilder,
      );

      final paddedGrid = SliverPadding(padding: effectivePadding, sliver: grid);

      if (screenWidth > maxWidthSize) {
        final horizontalPadding = (screenWidth - maxWidthSize) / 2;
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: paddedGrid,
        );
      }

      return paddedGrid;
    }

    final grid = MasonryGridView.count(
      controller: scrollController,
      physics: physics,
      padding: effectivePadding is EdgeInsets ? effectivePadding : null,
      crossAxisCount: itemsPerRow,
      mainAxisSpacing: Sizes.p8,
      crossAxisSpacing: Sizes.p8,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );

    return ResponsiveCenter(maxContentWidth: maxWidthSize, child: grid);
  }
}
