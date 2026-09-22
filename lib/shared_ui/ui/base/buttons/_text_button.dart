part of 'base_button.dart';

class _TextButtonWrapper extends StatelessWidget {
  const _TextButtonWrapper({
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
        onPressed: onTap,
        padding: padding ?? EdgeInsets.zero,
        minimumSize: Size.zero,
        child: child,
      );
    }

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: padding,
        elevation: elevation,
      ),
      child: child,
    );
  }
}
