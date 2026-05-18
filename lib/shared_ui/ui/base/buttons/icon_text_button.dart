import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/ui_helpers.dart';
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
    return InkWell(
      onTap: onPressed,
      borderRadius: UIHelpers.radiusC4,
      child: Padding(
        padding: UIHelpers.paddingA4,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            platformIcon,
            UIHelpers.spaceH4,
            BaseText(text, color: textColor),
          ],
        ),
      ),
    );
  }
}
