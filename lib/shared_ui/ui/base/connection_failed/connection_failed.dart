import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/connection_failed/network_tower.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ConnectionFailed extends StatelessWidget {
  const ConnectionFailed({super.key, required this.callBack});
  final Future<void> Function() callBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          gapH12,
          const NetworkTower(),
          gapH24,
          BaseText.headlineLarge('Whoops!'),
          BaseText.title('Connection Failure 🛰️', textAlign: TextAlign.center),
          const Spacer(),
          BaseButton(
            expandWidth: true,
            onTap: callBack,
            color: Colors.indigo,
            text: 'Try Again',
          ),
        ],
      ),
    );
  }
}
