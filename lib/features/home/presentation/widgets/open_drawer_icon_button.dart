import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class OpenDrawerIconButton extends StatelessWidget {
  const OpenDrawerIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      onPressed: Scaffold.of(context).openDrawer,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.menu,
        cupertinoIcon: CupertinoIcons.bars,
      ),
    );
  }
}
