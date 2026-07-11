import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/quick_action_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class FastActions extends StatelessWidget {
  const FastActions({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                onTap: () => cubit.navigateToCreateUpdateWorkOrder(),
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
                onTap: () => cubit.navigateToCreateUpdateAsset(),
              ),
            ),
          ],
        ),
        gapH12,
      ],
    );
  }
}
