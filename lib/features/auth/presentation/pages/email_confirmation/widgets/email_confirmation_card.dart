import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/email_confirmation/widgets/email_confirmation_button.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/email_confirmation/widgets/email_confirmation_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class EmailConfirmationCard extends StatelessWidget {
  const EmailConfirmationCard({
    super.key,
    required this.size,
    required this.theme,
    required this.controller,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.onPressed,
  });

  final Size size;
  final ThemeData theme;
  final AnimationController controller;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        width: size.width > 480 ? 400 : double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF161C24).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmailConfirmationIcon(
              controller: controller,
              scaleAnimation: scaleAnimation,
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: opacityAnimation,
              child: const Column(
                children: [
                  BaseText(
                    'E-mail verificado',
                    textAlign: TextAlign.center,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  SizedBox(height: 12),
                  BaseText(
                    'Seu e-mail foi verificado com sucesso. Agora você pode retornar ao aplicativo e entrar para explorar seu painel.',
                    textAlign: TextAlign.center,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: opacityAnimation,
              child: EmailConfirmationButton(onPressed: onPressed),
            ),
            const SizedBox(height: 24),
            BaseText(
              'ServiceProviders',
              color: Colors.white.withValues(alpha: 0.3),
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}
