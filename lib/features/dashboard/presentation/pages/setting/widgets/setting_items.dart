import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/constants/app_icons.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/cubits/theme/theme_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_switch.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
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
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          const SettingsItem(),
          const SizedBox(height: Sizes.p12),
          Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.p4),
              child: Row(
                children: [
                  const PlatformIcon(
                    materialIcon: Icons.dark_mode_outlined,
                    cupertinoIcon: CupertinoIcons.moon_fill,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BlocSelector<ThemeCubit, ThemeState, ThemeMode>(
                      selector: (state) => state.themeMode,
                      builder: (context, themeMode) {
                        final isDark =
                            context.theme.brightness == Brightness.dark;
                        return DefaultSwitch(
                          title: 'Dark Mode'.hardcoded,
                          value: isDark,
                          onChanged: (value) {
                            context.read<ThemeCubit>().updateThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () {},
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Sizes.p12)),
          side: BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Sizes.p16,
          vertical: Sizes.p8,
        ),
        horizontalTitleGap: 8,
        leading: const PlatformIcon(
          materialIcon: AppIcons.lock,
          cupertinoIcon: CupertinoIcons.lock_fill,
          size: 22,
        ),
        title: BaseText.bodyLarge('Alterar senha'.hardcoded),
        trailing: const PlatformIcon(
          materialIcon: AppIcons.arrowRight,
          cupertinoIcon: CupertinoIcons.chevron_forward,
          size: 22,
        ),
      ),
    );
  }
}
