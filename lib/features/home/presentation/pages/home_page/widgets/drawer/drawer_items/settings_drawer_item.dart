import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_drawer_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Navigation item for the home drawer to go to the global application settings screen.
class SettingsDrawerItem extends StatelessWidget {
  const SettingsDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDrawerItem(
      title: 'Configurações'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.settings_outlined,
        cupertinoIcon: CupertinoIcons.settings,
      ),
      onTap: context.read<HomeCubit>().navigateToConfigurations,
    );
  }
}
