import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseBottomNavigationBarItem {
  const BaseBottomNavigationBarItem({
    required this.platformIcon,
    this.label,
    this.tooltip,
  });

  final PlatformIcon platformIcon;
  final String? label;
  final String? tooltip;
}

class BaseBottomNavigationBar extends StatelessWidget {
  const BaseBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BaseBottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).bottomNavigationBarTheme;
    final isDark = context.theme.brightness == Brightness.dark;

    // Premium separation border
    final borderSideColor = isDark ? const Color(0xFF334155) : AppColors.border;
    final border = Border(top: BorderSide(color: borderSideColor, width: 0.5));

    if (context.isCupertino) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        activeColor: theme.selectedItemColor,
        inactiveColor: theme.unselectedItemColor ?? const Color(0xFF64748B),
        backgroundColor: theme.backgroundColor,
        border: border,
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(
              item.platformIcon.cupertinoIcon,
              size: item.platformIcon.size,
            ),
            label: item.label,
            tooltip: item.tooltip,
          );
        }).toList(),
      );
    }

    return Container(
      decoration: BoxDecoration(color: theme.backgroundColor, border: border),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(
              item.platformIcon.materialIcon,
              size: item.platformIcon.size,
            ),
            label: item.label ?? '',
            tooltip: item.tooltip,
          );
        }).toList(),
      ),
    );
  }
}
