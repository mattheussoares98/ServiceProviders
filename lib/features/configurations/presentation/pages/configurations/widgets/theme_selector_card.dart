import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/configuration_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

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
      actionWidget: const Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          Flexible(
            child: _ThemeOptionButton(
              platformIcon: PlatformIcon(
                materialIcon: Icons.light_mode_outlined,
                cupertinoIcon: CupertinoIcons.sun_max,
              ),
              theme: ThemeMode.light,
            ),
          ),
          gapW8,
          Flexible(
            child: _ThemeOptionButton(
              platformIcon: PlatformIcon(
                materialIcon: Icons.dark_mode_outlined,
                cupertinoIcon: CupertinoIcons.moon_stars,
              ),
              theme: ThemeMode.dark,
            ),
          ),
          gapW8,
          Flexible(
            child: _ThemeOptionButton(
              platformIcon: PlatformIcon(
                materialIcon: Icons.brightness_auto_outlined,
                cupertinoIcon: CupertinoIcons.globe,
              ),
              theme: ThemeMode.system,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  const _ThemeOptionButton({required this.platformIcon, required this.theme});

  final PlatformIcon platformIcon;
  final ThemeMode theme;

  @override
  Widget build(BuildContext context) {
    final label = switch (theme) {
      ThemeMode.light => 'Claro'.hardcoded,
      ThemeMode.dark => 'Escuro'.hardcoded,
      ThemeMode.system => 'Sistema'.hardcoded,
    };
    return BlocSelector<ConfigurationsCubit, ConfigurationsState, ThemeMode>(
      selector: (state) => state.themeMode,
      builder: (context, currentMode) {
        final selected = theme == currentMode;
        return SizedBox(
          width: 200,
          child: InkWell(
            onTap: () =>
                context.read<ConfigurationsCubit>().updateThemeMode(theme),
            borderRadius: BorderRadius.circular(Sizes.p8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: Sizes.p12,
                horizontal: Sizes.p8,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? context.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      )
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? context.colorScheme.primary
                      : context.colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
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
      },
    );
  }
}
