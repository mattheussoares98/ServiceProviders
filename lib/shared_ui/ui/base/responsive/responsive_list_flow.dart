import 'dart:math';

import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ResponsiveListFlow extends StatelessWidget {
  const ResponsiveListFlow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.maxItemWidth = 380,
    this.isSliver = false,
    this.padding,
    this.physics,
  });
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double? maxItemWidth;
  final bool isSliver;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = theme.platform == TargetPlatform.iOS;
    final isAndroid = theme.platform == TargetPlatform.android;

    if (isIOS || isAndroid) {
      return isSliver
          ? SliverList.builder(itemBuilder: itemBuilder, itemCount: itemCount)
          : ListView.builder(
              physics: physics,
              padding: padding,
              itemBuilder: itemBuilder,
              itemCount: itemCount,
            );
    }

    final width = MediaQuery.of(context).size.width;
    // Calculate how many items fit in one row
    final itemsPerRow = max((width / maxItemWidth!).floor(), 1);
    // Calculate the total number of rows needed
    final rowCount = (itemCount / itemsPerRow).ceil();

    if (isSliver) {
      return SliverList.builder(
        itemCount: rowCount,
        itemBuilder: (context, rowIndex) {
          return _RowsItems(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            itemsPerRow: itemsPerRow,
            rowIndex: rowIndex,
          );
        },
      );
    }

    return ListView.builder(
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, rowIndex) {
        return _RowsItems(
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          itemsPerRow: itemsPerRow,
          rowIndex: rowIndex,
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
  });
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemsPerRow;
  final int rowIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
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
  }
}
