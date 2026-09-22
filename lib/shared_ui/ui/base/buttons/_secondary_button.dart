part of 'base_button.dart';

class _SecondaryButtonWrapper extends StatelessWidget {
  const _SecondaryButtonWrapper({
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
    final activeColor = color ?? context.colorScheme.primary;

    if (context.isCupertino) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: activeColor, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(Sizes.p8)),
        ),
        child: CupertinoButton(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: Sizes.p12),
          onPressed: onTap,
          child: Center(child: child),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(elevation: elevation, padding: padding)
          .copyWith(
            side: WidgetStateProperty.all(
              BorderSide(color: activeColor, width: 1.5),
            ),
          ),
      child: child,
    );
  }
}
