import 'package:clean_architecture/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SecondaryButton extends HookWidget {
  const SecondaryButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textType = TextType.bodyLarge,
    this.textFontWeight = FontWeight.w500,
    this.foregroundColor,
    this.height,
    this.width,
    this.color,
    this.loadableButton = false,
    this.elevation,
    this.expandWidth = false,
  });
  final Future<void> Function() onTap;
  final String text;
  final TextType textType;
  final FontWeight textFontWeight;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final bool loadableButton;
  final Color? color;
  final double? elevation;
  final bool expandWidth;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? context.colorScheme.primary;
    final activeForegroundColor =
        foregroundColor ?? context.colorScheme.primary;
    final loadingNotifier = useValueNotifier(false);
    final onPressed = useCallback(() async {
      /// If the button is loading, discard the task
      if (loadingNotifier.value) {
        return;
      }

      /// If the button is not loadable
      if (!loadableButton) {
        return onTap();
      }

      loadingNotifier.value = true;
      await onTap();

      /// If the widget is disposed, don't update value
      if (context.mounted) {
        loadingNotifier.value = false;
      }
    });

    return SizedBox(
      height: height ?? 50,
      width: expandWidth ? double.maxFinite : width,
      child: ValueListenableBuilder(
        valueListenable: loadingNotifier,
        builder: (builderContext, loading, setState) {
          final childWidget = loading
              ? LoadingCircle.small(activeForegroundColor)
              : BaseText(
                  text,
                  color: activeForegroundColor,
                  textType: textType,
                  fontWeight: textFontWeight,
                );

          if (context.isCupertino) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: activeColor, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(Sizes.p8)),
              ),
              child: CupertinoButton(
                onPressed: loading ? null : onPressed.call,
                padding: EdgeInsets.zero,
                child: Center(child: childWidget),
              ),
            );
          }

          return OutlinedButton(
            onPressed: loading ? null : onPressed.call,
            style: OutlinedButton.styleFrom().copyWith(
              side: WidgetStateProperty.all(
                BorderSide(color: activeColor, width: 1.5),
              ),
            ),
            child: childWidget,
          );
        },
      ),
    );
  }
}
