import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/constants/app_icons.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/dashboard/presentation/pages/setting/widgets/setting_item.dart';
import 'package:clean_architecture/shared_ui/cubits/theme/theme_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingItems extends StatelessWidget {
  const SettingItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.p16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(Sizes.p12)),
        boxShadow: const [BoxShadow(color: AppColors.black15, blurRadius: 24)],
      ),
      child: Column(
        children: [
          SettingsItem(
            title: 'Alterar senha'.hardcoded,
            leading: const PlatformIcon(
              materialIcon: AppIcons.lock,
              cupertinoIcon: CupertinoIcons.lock_fill,
            ),
            trailing: const PlatformIcon(
              materialIcon: AppIcons.arrowRight,
              cupertinoIcon: CupertinoIcons.chevron_forward,
            ),
            onTap: () {},
          ),
          gapH8,
          BlocSelector<ThemeCubit, ThemeState, ThemeMode>(
            selector: (state) => state.themeMode,
            builder: (context, themeMode) {
              final isDark = context.theme.brightness == Brightness.dark;
              return SettingsItem.switchType(
                title: 'Dark Mode'.hardcoded,
                leading: const PlatformIcon(
                  materialIcon: Icons.dark_mode_outlined,
                  cupertinoIcon: CupertinoIcons.moon_fill,
                ),
                value: isDark,
                onChanged: (value) {
                  context.read<ThemeCubit>().updateThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
