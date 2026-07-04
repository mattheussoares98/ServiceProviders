import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';

class BaseIndicationItem extends StatelessWidget {
  const BaseIndicationItem({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p8,
        vertical: Sizes.p4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Sizes.p8),
      ),
      child: BaseText.caption(label, color: color, fontWeight: FontWeight.bold),
    );
  }
}
