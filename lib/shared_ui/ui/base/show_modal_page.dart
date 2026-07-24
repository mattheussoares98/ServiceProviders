import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

Future<T?> showModalPage<T>(
  Widget body,
  BuildContext context, {
  bool isScrollControlled = true,
  bool useDraggable = true,
  double initialChildSize = 0.95,
  double minChildSize = 0.5,
  double maxChildSize = 0.95,
}) async {
  final result = await showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) {
      if (!useDraggable) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(onTap: Navigator.of(context).pop),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(child: _Body(body: body, expand: false)),
            ),
          ],
        );
      }
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(onTap: Navigator.of(context).pop),
          ),
          DraggableScrollableSheet(
            expand: false,
            initialChildSize: initialChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            builder: (_, controller) {
              return SafeArea(child: _Body(body: body));
            },
          ),
        ],
      );
    },
  );
  return result;
}

class _Body extends StatelessWidget {
  const _Body({required this.body, this.expand = true});
  final Widget body;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //dragglable indicator
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: Sizes.p12),
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (expand)
            Expanded(
              child: Scaffold(backgroundColor: Colors.transparent, body: body),
            )
          else
            Flexible(
              child: Material(color: Colors.transparent, child: body),
            ),
          // const SizedBox(height: Sizes.p12),
        ],
      ),
    );
  }
}
