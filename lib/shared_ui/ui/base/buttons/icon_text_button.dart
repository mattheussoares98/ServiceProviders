import 'dart:async';

import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class IconTextButton extends HookWidget {
  const IconTextButton({
    super.key,
    required this.onPressed,
    required this.platformIcon,
    required this.text,
    this.textColor,
  });
  final FutureOr<void> Function()? onPressed;
  final PlatformIcon platformIcon;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isLoading = useState(false);

    final tapCallback = onPressed == null
        ? null
        : () async {
            final result = onPressed!();
            if (result is Future) {
              isLoading.value = true;
              try {
                await result;
              } finally {
                if (context.mounted) {
                  isLoading.value = false;
                }
              }
            }
          };

    const padding = EdgeInsets.all(Sizes.p4);
    const radius = BorderRadius.all(Radius.circular(Sizes.p4));
    const verticalSpace = gapH4;

    final effectiveColor = textColor ?? context.colorScheme.primary;

    final iconWidget = isLoading.value
        ? LoadingCircle.small(effectiveColor)
        : platformIcon;

    if (context.isCupertino) {
      return CupertinoButton(
        onPressed: isLoading.value ? null : tapCallback,
        padding: padding,
        borderRadius: radius,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            verticalSpace,
            BaseText(text, color: textColor),
          ],
        ),
      );
    }

    return InkWell(
      onTap: isLoading.value ? null : tapCallback,
      borderRadius: radius,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            verticalSpace,
            BaseText(text, color: textColor),
          ],
        ),
      ),
    );
  }
}
