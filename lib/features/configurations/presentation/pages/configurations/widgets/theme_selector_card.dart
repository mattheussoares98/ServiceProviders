import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/configurations/presentation/pages/configurations/widgets/configuration_item.dart';
import 'package:clean_architecture/shared_ui/cubits/theme/theme_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeSelectorCard extends StatelessWidget {
  const ThemeSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfigurationItem(
      platformIcon: const PlatformIcon(
        materialIcon: Icons.brightness_6_outlined,
        cupertinoIcon: CupertinoIcons.brightness,
      ),
      title: 'Tema'.hardcoded,
      subtitle: 'Escolha a aparência visual do aplicativo'.hardcoded,
      actionWidget: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final currentMode = state.themeMode;
          return Row(
            mainAxisAlignment: .spaceEvenly,
            children: [
              Flexible(
                child: _ThemeOptionButton(
                  label: 'Claro'.hardcoded,
                  platformIcon: const PlatformIcon(
                    materialIcon: Icons.light_mode_outlined,
                    cupertinoIcon: CupertinoIcons.sun_max,
                  ),
                  selected: currentMode == ThemeMode.light,
                  onTap: () => context.read<ThemeCubit>().updateThemeMode(
                    ThemeMode.light,
                  ),
                ),
              ),
              gapW8,
              Flexible(
                child: _ThemeOptionButton(
                  label: 'Escuro'.hardcoded,
                  platformIcon: const PlatformIcon(
                    materialIcon: Icons.dark_mode_outlined,
                    cupertinoIcon: CupertinoIcons.moon_stars,
                  ),
                  selected: currentMode == ThemeMode.dark,
                  onTap: () => context.read<ThemeCubit>().updateThemeMode(
                    ThemeMode.dark,
                  ),
                ),
              ),
              gapW8,
              Flexible(
                child: _ThemeOptionButton(
                  label: 'Sistema'.hardcoded,
                  platformIcon: const PlatformIcon(
                    materialIcon: Icons.brightness_auto_outlined,
                    cupertinoIcon: CupertinoIcons.globe,
                  ),
                  selected: currentMode == ThemeMode.system,
                  onTap: () => context.read<ThemeCubit>().updateThemeMode(
                    ThemeMode.system,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  const _ThemeOptionButton({
    required this.label,
    required this.platformIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final PlatformIcon platformIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.p8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Sizes.p12,
            horizontal: Sizes.p8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? context.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? context.colorScheme.primary
                  : context.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: selected ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(Sizes.p8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              platformIcon.copyWith(
                color: selected
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
              gapH4,
              BaseText(
                label,
                color: selected
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
