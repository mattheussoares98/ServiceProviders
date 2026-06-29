import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_drawer_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Navigation item for the home drawer to go to the permissions management screen.
class PermissionsDrawerItem extends StatelessWidget {
  const PermissionsDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDrawerItem(
      title: 'Usuários e permissões'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.vpn_key_outlined,
        cupertinoIcon: CupertinoIcons.lock,
      ),
      onTap: context.read<HomeCubit>().navigateToPermissions,
    );
  }
}
