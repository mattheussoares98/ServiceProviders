import 'package:clean_architecture/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:flutter/material.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      onTap: () async => onTap(),
      text: label,
      expandWidth: true,
    );
  }
}
