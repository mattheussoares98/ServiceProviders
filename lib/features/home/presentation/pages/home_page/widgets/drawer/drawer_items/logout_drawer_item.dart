import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Navigation item for the home drawer to log out the user from their active session.
class LogoutDrawerItem extends StatelessWidget {
  const LogoutDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseListTile(
      title: 'Sair'.hardcoded,
      platformIcon: PlatformIcon(
        materialIcon: Icons.logout,
        cupertinoIcon: CupertinoIcons.square_arrow_right,
        color: context.theme.colorScheme.error,
      ),
      onTap: () async {
        Navigator.of(context).pop();
        await context.read<HomeCubit>().logout();
      },
    );
  }
}
