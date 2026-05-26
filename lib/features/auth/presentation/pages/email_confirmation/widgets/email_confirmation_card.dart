import 'package:clean_architecture/features/auth/presentation/pages/email_confirmation/widgets/email_confirmation_button.dart';
import 'package:clean_architecture/features/auth/presentation/pages/email_confirmation/widgets/email_confirmation_icon.dart';
import 'package:flutter/material.dart';

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
              child: Column(
                children: [
                  Text(
                    'E-mail Verificado',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Seu e-mail foi verificado com sucesso. Agora você pode retornar ao aplicativo e entrar para explorar seu painel.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF9CA3AF),
                      height: 1.5,
                    ),
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
            Text(
              'ServiceProviders',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.3),
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
