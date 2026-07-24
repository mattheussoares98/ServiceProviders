import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class OpenDrawerIconButton extends StatelessWidget {
  const OpenDrawerIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      onPressed: () {
        var scaffoldState = Scaffold.maybeOf(context);
        while (scaffoldState != null && !scaffoldState.hasDrawer) {
          scaffoldState = scaffoldState.context
              .findAncestorStateOfType<ScaffoldState>();
        }
        scaffoldState?.openDrawer();
      },
      platformIcon: const PlatformIcon(
        materialIcon: Icons.menu,
        cupertinoIcon: CupertinoIcons.bars,
      ),
    );
  }
}
