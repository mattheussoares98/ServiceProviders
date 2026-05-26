import 'package:flutter/material.dart';

class EmailConfirmationIcon extends StatelessWidget {
  const EmailConfirmationIcon({
    super.key,
    required this.controller,
    required this.scaleAnimation,
  });

  final AnimationController controller;
  final Animation<double> scaleAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.25),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                spreadRadius: 2 * controller.value,
              ),
            ],
          ),
          child: ScaleTransition(
            scale: scaleAnimation,
            child: const Icon(
              Icons.check_rounded,
              size: 48,
              color: Color(0xFF10B981),
            ),
          ),
        );
      },
    );
  }
}
