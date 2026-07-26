import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

@RoutePage()
class ModeSwitcherPage extends StatelessWidget {
  const ModeSwitcherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BaseText.title('Como deseja acessar?'.hardcoded),
          gapH8,
          BaseText(
            'Sua conta possui acesso de funcionário interno e de prestador de serviços'
                .hardcoded,
            textAlign: TextAlign.center,
          ),
          gapH48,
          BlocBuilder<ModeSwitcherCubit, ModeSwitcherState>(
            builder: (context, state) {
              final cubit = context.read<ModeSwitcherCubit>();
              final isLoading = state.status == StateStatus.loading;

              return Column(
                children: [
                  _ModeCard(
                    title: 'Funcionário da obra'.hardcoded,
                    description:
                        'Gerencie obras, ordens de serviço, ativos, locais e equipes'
                            .hardcoded,
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.business_outlined,
                      cupertinoIcon: CupertinoIcons.building_2_fill,
                    ),
                    isSelected: state.selectedMode == AppMode.internal,
                    isDisabled: isLoading,
                    onTap: () => cubit.selectMode(AppMode.internal),
                  ),
                  const SizedBox(height: 20),
                  _ModeCard(
                    title: 'Prestador de serviços'.hardcoded,
                    description:
                        'Acesse e atenda ordens de serviço externas da sua empresa'
                            .hardcoded,
                    platformIcon: const PlatformIcon(
                      materialIcon: Icons.handyman_outlined,
                      cupertinoIcon: CupertinoIcons.hammer,
                    ),
                    isSelected: state.selectedMode == AppMode.provider,
                    isDisabled: isLoading,
                    onTap: () => cubit.selectMode(AppMode.provider),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.platformIcon,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final String title;
  final String description;
  final PlatformIcon platformIcon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.colorScheme.primary;
    final cardColor = context.theme.cardColor;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : context.theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : context.theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: platformIcon.copyWith(
                color: isSelected ? Colors.white : primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaseText.title(
                    title,
                    color: isSelected
                        ? primaryColor
                        : context.theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 6),
                  BaseText(
                    description,
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.65,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
