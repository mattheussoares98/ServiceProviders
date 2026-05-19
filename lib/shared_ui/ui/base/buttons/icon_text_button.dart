import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  const IconTextButton({
    super.key,
    required this.onPressed,
    required this.platformIcon,
    required this.text,
    this.textColor,
  });
  final void Function() onPressed;
  final PlatformIcon platformIcon;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(Sizes.p4);
    const radius = BorderRadius.all(Radius.circular(Sizes.p4));
    const verticalSpace = gapH4;

    if (context.isCupertino) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: padding,
        borderRadius: radius,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            platformIcon,
            verticalSpace,
            BaseText(text, color: textColor),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: radius,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            platformIcon,
            verticalSpace,
            BaseText(text, color: textColor),
          ],
        ),
      ),
    );
  }
}
