import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/material.dart';

class AnimatedEllipsis extends StatefulWidget {
  const AnimatedEllipsis({super.key});

  @override
  State<AnimatedEllipsis> createState() => _AnimatedEllipsisState();
}

class _AnimatedEllipsisState extends State<AnimatedEllipsis>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    // PERFORMANCE: Animation duration is set to a reasonable human-readable
    // speed (1.5s) to avoid excessive UI thread work.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Linearly interpolates from 0 to 4 to represent ".", "..", "...", and ""
    _dotCount = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (context, child) {
        // Generates the string of dots based on the current animation value
        final dots = '.' * (_dotCount.value);
        return SizedBox(
          // PERFORMANCE: Using a fixed width prevents the text from shifting
          // adjacent widgets when the dot count changes (Layout Jitters).
          width: 24,
          child: Text(dots, style: context.theme.textTheme.titleMedium),
        );
      },
    );
  }
}
