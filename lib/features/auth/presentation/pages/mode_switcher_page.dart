import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

@RoutePage()
class ModeSwitcherPage extends StatelessWidget {
  const ModeSwitcherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<ModeSwitcherCubit>(
      create: (context) => GetIt.I<ModeSwitcherCubit>(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  'Como deseja acessar?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sua conta possui acesso de funcionário interno e de prestador de serviços.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 48),
                BlocBuilder<ModeSwitcherCubit, ModeSwitcherState>(
                  builder: (context, state) {
                    final cubit = context.read<ModeSwitcherCubit>();
                    final isLoading = state.status == StateStatus.loading;

                    return Column(
                      children: [
                        _ModeCard(
                          title: 'Funcionário da Obra',
                          description:
                              'Gerencie obras, ordens de serviço, ativos, locais e equipes.',
                          icon: Icons.business_outlined,
                          isSelected: state.selectedMode == AppMode.internal,
                          isDisabled: isLoading,
                          onTap: () => cubit.selectMode(AppMode.internal),
                          theme: theme,
                        ),
                        const SizedBox(height: 20),
                        _ModeCard(
                          title: 'Prestador de Serviços',
                          description:
                              'Acesse e atenda ordens de serviço externas da sua empresa.',
                          icon: Icons.handyman_outlined,
                          isSelected: state.selectedMode == AppMode.provider,
                          isDisabled: isLoading,
                          onTap: () => cubit.selectMode(AppMode.provider),
                          theme: theme,
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
    required this.theme,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;

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
            color: isSelected ? primaryColor : theme.dividerColor,
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
                color: isSelected ? primaryColor : theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? primaryColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                      height: 1.3,
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
