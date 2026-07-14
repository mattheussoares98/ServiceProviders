import 'dart:math';

import 'package:flutter/material.dart';
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
    final width = min(maxWidthSize, MediaQuery.of(context).size.width);
    // Calculate how many items fit in one row
    final itemsPerRow = max((width / maxItemWidth!).floor(), 1);
    // Calculate the total number of rows needed
    final rowCount = (itemCount / itemsPerRow).ceil();

    if (isSliver) {
      return SliverPadding(
        padding: effectivePadding,
        sliver: SliverList.builder(
          itemCount: rowCount,
          itemBuilder: (context, rowIndex) {
            return _RowsItems(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              itemsPerRow: itemsPerRow,
              rowIndex: rowIndex,
              maxWidthSize: maxWidthSize,
            );
          },
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: physics,
      itemCount: rowCount,
      padding: effectivePadding,
      itemBuilder: (context, rowIndex) {
        return _RowsItems(
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          itemsPerRow: itemsPerRow,
          rowIndex: rowIndex,
          maxWidthSize: maxWidthSize,
        );
      },
    );
  }
}

class _RowsItems extends StatelessWidget {
  const _RowsItems({
    required this.itemCount,
    required this.itemBuilder,
    required this.itemsPerRow,
    required this.rowIndex,
    this.maxWidthSize,
  });
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemsPerRow;
  final int rowIndex;
  final double? maxWidthSize;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemsPerRow, (colIndex) {
        final itemIndex = (rowIndex * itemsPerRow) + colIndex;

        if (itemIndex < itemCount) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: colIndex == 0 ? 0 : Sizes.p4,
                right: colIndex == itemsPerRow - 1 ? 0 : Sizes.p4,
                bottom: Sizes.p4,
              ),
              child: itemBuilder(context, itemIndex),
            ),
          );
        } else {
          return const Expanded(child: SizedBox());
        }
      }),
    );

    if (maxWidthSize != null) {
      return ResponsiveCenter(maxContentWidth: maxWidthSize!, child: row);
    }

    return row;
  }
}
