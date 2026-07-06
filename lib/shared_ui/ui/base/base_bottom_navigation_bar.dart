import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/badges/validated_badge.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class BaseBottomNavigationBarItem {
  const BaseBottomNavigationBarItem({
    required this.platformIcon,
    this.label,
    this.tooltip,
    this.isValid,
    this.badgeLabel,
    this.showSuccessBadge = true,
  });

  final PlatformIcon platformIcon;
  final String? label;
  final String? tooltip;
  final bool? isValid;
  final String? badgeLabel;
  final bool showSuccessBadge;
}

class BaseBottomNavigationBar extends StatelessWidget {
  const BaseBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.border = const Border(top: BorderSide(color: Colors.transparent)),
  });

  final List<BaseBottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).bottomNavigationBarTheme;
    final isCupertino = PlatformUtil.isCupertino;

    final List<BottomNavigationBarItem> localItems = items.map((e) {
      final isSelected = items.indexOf(e) == currentIndex;

      Widget icon = e.platformIcon;

      if (e.isValid != null) {
        icon = ValidatedBadge(
          isValid: e.isValid == true,
          platformIcon: icon as PlatformIcon,
          isSelected: isSelected,
          showSuccessBadge: e.showSuccessBadge,
        );
      }

      if (e.badgeLabel != null) {
        icon = Badge(
          label: BaseText(e.badgeLabel!),
          offset: const Offset(10, -2),
          alignment: Alignment.topRight,
          child: icon,
        );
      }

      if (isCupertino && e.label != null) {
        icon = GestureDetector(
          onTap: () => onTap(items.indexOf(e)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(child: icon),
              if (isSelected)
                FittedBox(child: BaseText.title(e.label!))
              else
                BaseText.bodySmall(e.label!, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      }

      return BottomNavigationBarItem(
        icon: icon,
        label: isCupertino ? null : (e.label ?? ''),
        tooltip: e.tooltip,
      );
    }).toList();

    // Premium separation border

    final Widget bottomBar;

    final buttonNavigationsHeight = MediaQuery.viewPaddingOf(context).bottom;

    final height = 64 + buttonNavigationsHeight;

    if (isCupertino) {
      bottomBar = CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        activeColor: theme.selectedItemColor,
        inactiveColor: theme.unselectedItemColor ?? const Color(0xFF64748B),
        backgroundColor: theme.backgroundColor,
        border: border,
        items: localItems,
        height: height,
      );
    } else {
      bottomBar = SizedBox(
        height: height,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: localItems,
          ),
        ),
      );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        bottomBar,
        Positioned(
          top: -2,
          left: 0,
          right: 0,
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(15)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
