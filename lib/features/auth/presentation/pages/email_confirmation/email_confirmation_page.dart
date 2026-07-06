import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/email_confirmation/widgets/email_confirmation_background.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/email_confirmation/widgets/email_confirmation_card.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class EmailConfirmationPage extends HookWidget {
  const EmailConfirmationPage({super.key});

  Future<void> _handleReturn(BuildContext context) async {
    if (kIsWeb) {
      unawaited(context.router.replaceAll([const LoginRoute()]));
    } else {
      final Uri appUri = Uri.parse(
        'serviceproviders://confirm',
      ); //TODO check how it work
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          unawaited(context.router.replaceAll([const LoginRoute()]));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final size = MediaQuery.sizeOf(context);

    // Flutter Hook: Animation Controller with single ticker provider automatically managed
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );

    // Flutter Hook: Memoize curved animations to avoid recreation on rebuild
    final scaleAnimation = useMemoized(
      () => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0, 0.6, curve: Curves.elasticOut),
        ),
      ),
      [controller],
    );

    final opacityAnimation = useMemoized(
      () => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.4, 1, curve: Curves.easeIn),
        ),
      ),
      [controller],
    );

    // Flutter Hook: Trigger animation on widget load. Will be called on every build
    useEffect(() {
      controller.forward();
      return null;
    }, [controller]);

    return BaseScaffold(
      isScrollable: false,
      usePadding: false,
      body: Stack(
        children: [
          const EmailConfirmationBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: EmailConfirmationCard(
                size: size,
                theme: theme,
                controller: controller,
                scaleAnimation: scaleAnimation,
                opacityAnimation: opacityAnimation,
                onPressed: () => _handleReturn(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
