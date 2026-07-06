import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final PlatformIcon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      onTap: onTap,
      text: label,
      expandWidth: true,
      platformIcon: icon,
    );
  }
}
