import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

Future<T?> showModalPage<T>(Widget body, BuildContext context) async {
  final result = await showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true, // Allows the modal to be full-screen
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(onTap: Navigator.of(context).pop),
          ),
          DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.95,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) {
              //TODO test using BaseScaffold below
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
  const _Body({required this.body});
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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
          Expanded(
            child: Scaffold(backgroundColor: Colors.transparent, body: body),
          ),
          // const SizedBox(height: Sizes.p12),
        ],
      ),
    );
  }
}
