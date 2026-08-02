import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/provider_home/provider_home_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class ProviderLogoutDrawerItem extends StatelessWidget {
  const ProviderLogoutDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDrawerItem(
      title: 'Sair'.hardcoded,
      closeAutomatically: false,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.logout,
        cupertinoIcon: CupertinoIcons.square_arrow_right,
        color: Colors.red,
      ),
      onTap: () async {
        await showAlertDialog(
          context: context,
          title: 'Deseja realmente sair?'.hardcoded,
          onOkPressed: () {
            context.pop();
            context.read<ProviderHomeCubit>().logout();
          },
          cancelActionText: 'Não'.hardcoded,
          defaultActionText: 'Sim'.hardcoded,
        );
      },
    );
  }
}
