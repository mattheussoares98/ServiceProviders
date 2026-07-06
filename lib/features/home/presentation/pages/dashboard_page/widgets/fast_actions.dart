import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/quick_action_button.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class FastActions extends StatelessWidget {
  const FastActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        BaseText.title('Ações rápidas'.hardcoded),
        gapH4,
        Row(
          children: [
            Flexible(
              child: QuickActionButton(
                label: 'Nova ordem'.hardcoded,
                icon: const PlatformIcon(
                  materialIcon: Icons.add_task,
                  cupertinoIcon: CupertinoIcons.check_mark_circled,
                ),
                onTap: () => context.router.push(CreateUpdateWorkOrderRoute()),
              ),
            ),
            gapW12,
            Flexible(
              child: QuickActionButton(
                label: 'Novo equipamento'.hardcoded,
                icon: const PlatformIcon(
                  materialIcon: Icons.add_box_outlined,
                  cupertinoIcon: CupertinoIcons.add_circled,
                ),
                onTap: () => context.router.push(CreateUpdateAssetRoute()),
              ),
            ),
          ],
        ),
        gapH12,
      ],
    );
  }
}
