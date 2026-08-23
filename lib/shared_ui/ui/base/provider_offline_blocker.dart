import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/constants/app_colors.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ProviderOfflineBlocker extends StatefulWidget {
  const ProviderOfflineBlocker({super.key});

  @override
  State<ProviderOfflineBlocker> createState() => _ProviderOfflineBlockerState();
}

class _ProviderOfflineBlockerState extends State<ProviderOfflineBlocker> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    await context.read<OfflineAdvisoryCubit>().retryConnection();
    if (mounted) {
      setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.scaffoldBackgroundColor.withAlpha(200),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.p24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: PlatformIcon(
                      materialIcon: Icons.wifi_off_rounded,
                      cupertinoIcon: CupertinoIcons.wifi_slash,
                      size: 44,
                      color: AppColors.error,
                    ),
                  ),
                ),
                gapH24,
                BaseText.headline(
                  'Sem conexão com a internet'.hardcoded,
                  textAlign: TextAlign.center,
                ),
                gapH12,
                BaseText.bodyLarge(
                  'O modo prestador de serviços requer uma conexão ativa com a internet para sincronizar e gerenciar as ordens de serviço'
                      .hardcoded,
                  textAlign: TextAlign.center,
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.7)
                      : AppColors.fade,
                ),
                gapH32,
                BaseButton(
                  expandWidth: true,
                  text: 'Tentar novamente'.hardcoded,
                  isLoading: _isRetrying,
                  onTap: _handleRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
