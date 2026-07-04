import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_drawer_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Navigation item for the home drawer to log out the user from their active session.
class LogoutDrawerItem extends StatelessWidget {
  const LogoutDrawerItem({super.key});

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
            context.read<HomeCubit>().logout();
          },
          cancelActionText: 'Não'.hardcoded,
          defaultActionText: 'Sim'.hardcoded,
        );
      },
    );
  }
}
