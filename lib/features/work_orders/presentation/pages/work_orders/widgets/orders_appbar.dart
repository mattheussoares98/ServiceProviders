import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrdersAppbar extends StatelessWidget {
  const OrdersAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseAppBar(
      title: 'Ordens de Serviço'.hardcoded,
      leading: BaseIconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        platformIcon: const PlatformIcon(
          materialIcon: Icons.menu,
          cupertinoIcon: CupertinoIcons.bars,
        ),
      ),
      actions: [
        BaseIconButton(
          onPressed: () {
            showModalPage<void>(const Center(child: BaseText('Test')), context);
          },
          platformIcon: const PlatformIcon(
            materialIcon: Icons.add,
            cupertinoIcon: CupertinoIcons.add,
          ),
        ),
      ],
    );
  }
}
