import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/material.dart';

/// The premium header component of the HomeDrawer, styled with linear gradients.
class HomeDrawerHeader extends StatelessWidget {
  const HomeDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.colorScheme.primary,
            context.theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: context.theme.colorScheme.onPrimary,
              child: Icon(
                Icons.person,
                size: 35,
                color: context.theme.colorScheme.primary,
              ),
            ),
            gapH12,
            Text(
              'Olá, Usuário!'.hardcoded,
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: context.theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
