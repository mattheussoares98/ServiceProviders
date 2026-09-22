part of 'base_button.dart';

class _PrimaryButtonWrapper extends StatelessWidget {
  const _PrimaryButtonWrapper({
    required this.child,
    required this.onTap,
    this.color,
    this.elevation,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (context.isCupertino) {
      return CupertinoButton(
        padding: padding,
        onPressed: onTap,
        color: color ?? AppColors.primary,
        disabledColor: context.theme.disabledColor,
        borderRadius: const BorderRadius.all(Radius.circular(Sizes.p8)),
        child: Center(child: child),
      );
    }

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: elevation,
        padding: padding,
      ),
      child: child,
    );
  }
}
