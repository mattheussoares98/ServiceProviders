import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar({
    super.key,
    this.showLeading = true,
    this.leading,
    required this.title,
    this.titleWidget,
    this.titleFontWeight,
    this.titleStyle,
    this.centerTitle = false,
    this.actions,
    this.subtitle,
    this.actionsPadding,
  });
  final bool showLeading;
  final Widget? leading;
  final String title;
  final Widget? titleWidget;
  final FontWeight? titleFontWeight;
  final TextStyle? titleStyle;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? subtitle;
  final EdgeInsetsGeometry? actionsPadding;

  BaseAppBar copyWith({
    bool? showLeading,
    Widget? leading,
    String? title,
    Widget? titleWidget,
    FontWeight? titleFontWeight,
    TextStyle? titleStyle,
    bool? centerTitle,
    List<Widget>? actions,
    Widget? subtitle,
  }) {
    return BaseAppBar(
      key: key,
      showLeading: showLeading ?? this.showLeading,
      leading: leading ?? this.leading,
      title: title ?? this.title,
      titleWidget: titleWidget ?? this.titleWidget,
      titleFontWeight: titleFontWeight ?? this.titleFontWeight,
      titleStyle: titleStyle ?? this.titleStyle,
      centerTitle: centerTitle ?? this.centerTitle,
      actions: actions ?? this.actions,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppBar padding
    final double horizontalPadding = ScreenUtil.I.horizontalSpace;
    // AppBar leading height and width
    const double leadingSize = 40;
    // The maximum width of the AppBar leading
    final double leadingWidth = showLeading
        ? horizontalPadding + leadingSize
        : 0;
    // Space between Leading and title
    final double titleSpacing = showLeading ? 8 : horizontalPadding;

    Widget? leadingWidget;
    Widget? appBarTitleWidget;

    if (showLeading) {
      if (leading != null) {
        leadingWidget = leading;
      } else if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
        leadingWidget = BaseIconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          platformIcon: PlatformIcon(
            materialIcon: Icons.menu,
            cupertinoIcon: CupertinoIcons.bars,
            size: 20,
            color: context.colorScheme.onSurface,
          ),
        );
      } else {
        leadingWidget = BaseIconButton(
          onPressed: () => Navigator.maybePop(
            context,
          ), //!only method that queries the widget tree for active
          //!PopScopes (to check if canPop is false) before actually popping
          platformIcon: PlatformIcon(
            materialIcon: Icons.arrow_back,
            cupertinoIcon: CupertinoIcons.back,
            size: 20,
            color: context.colorScheme.onSurface,
          ),
        );
      }
    }

    if (title.isNotEmpty || titleWidget != null || subtitle != null) {
      final centerTitle = !PlatformUtil.isAndroid;
      final crossAxisAlignment = centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start;

      appBarTitleWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (titleWidget != null)
            titleWidget!
          else if (title.isNotEmpty) ...[
            FittedBox(child: BaseText.titleMedium(title)),
          ],
          if (subtitle != null)
            Align(alignment: Alignment.centerLeft, child: subtitle),
        ],
      );
    }

    if (context.isCupertino) {
      final topPadding = MediaQuery.paddingOf(context).top;
      return Container(
        height: _appBarHeight + topPadding,
        padding: EdgeInsets.only(top: topPadding),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          border: const Border(bottom: BorderSide(color: Colors.transparent)),
        ),
        child: Row(
          children: [
            if (showLeading)
              SizedBox(width: leadingWidth, child: leadingWidget),
            Expanded(flex: 2, child: Center(child: appBarTitleWidget)),
            if (actions != null)
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [...?actions?.map((e) => Flexible(child: e))],
                ),
              )
            else if (showLeading)
              SizedBox(width: leadingWidth),
          ],
        ),
      );
    }

    return AppBar(
      automaticallyImplyLeading: false,
      leading: leadingWidget,
      leadingWidth: leadingWidth,
      titleSpacing: titleSpacing,
      title: appBarTitleWidget,
      centerTitle: centerTitle,
      actions: actions,
      actionsPadding: actionsPadding,
      toolbarHeight: preferredSize.height + MediaQuery.paddingOf(context).top,
    );
  }

  double get _appBarHeight {
    double value = 50;
    if (subtitle != null) {
      return value += 14;
    } else if (actionsPadding != null) {
      return value += actionsPadding?.vertical ?? 0;
    }
    return value;
  }

  @override
  Size get preferredSize => Size.fromHeight(_appBarHeight);
}
