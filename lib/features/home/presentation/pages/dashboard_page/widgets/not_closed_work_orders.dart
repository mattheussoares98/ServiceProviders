import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/dashboard/dashboard_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/stats_card.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class NotClosedWorkOrders extends StatelessWidget {
  const NotClosedWorkOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DashboardCubit, DashboardState, (int, int, int)>(
      selector: (state) => (
        state.openWorkOrdersCount,
        state.inProgressWorkOrdersCount,
        state.pendingRevisionsCount,
      ),
      builder: (_, values) {
        final (
          openWorkOrdersCount,
          inProgressWorkOrdersCount,
          pendingRevisionsCount,
        ) = values;
        final total =
            openWorkOrdersCount +
            inProgressWorkOrdersCount +
            pendingRevisionsCount;

        if (total <= 0) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: StatsCard(
                    title: 'Abertas'.hardcoded,
                    value: openWorkOrdersCount.toString(),
                    icon: const PlatformIcon(
                      materialIcon: Icons.assignment_outlined,
                      cupertinoIcon: CupertinoIcons.list_bullet,
                    ),
                    color: Colors.blue,
                    onTap: () {},
                  ),
                ),
                gapW8,
                Flexible(
                  child: StatsCard(
                    title: 'Andamento'.hardcoded,
                    value: inProgressWorkOrdersCount.toString(),
                    icon: const PlatformIcon(
                      materialIcon: Icons.play_arrow_outlined,
                      cupertinoIcon: CupertinoIcons.play_circle,
                    ),
                    color: Colors.amber,
                    onTap: () {},
                  ),
                ),
                gapW8,
                Flexible(
                  child: StatsCard(
                    title: 'Revisões'.hardcoded,
                    value: pendingRevisionsCount.toString(),
                    icon: const PlatformIcon(
                      materialIcon: Icons.warning_amber_outlined,
                      cupertinoIcon: CupertinoIcons.exclamationmark_triangle,
                    ),
                    color: Colors.orange,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            gapH12,
            ClipRRect(
              borderRadius: BorderRadius.circular(Sizes.p4),
              child: SizedBox(
                height: 6,
                width: double.infinity,
                child: Row(
                  children: [
                    if (openWorkOrdersCount > 0)
                      Expanded(
                        flex: openWorkOrdersCount,
                        child: Container(
                          color: Colors.blue.withValues(alpha: 0.8),
                        ),
                      ),
                    if (inProgressWorkOrdersCount > 0)
                      Expanded(
                        flex: inProgressWorkOrdersCount,
                        child: Container(
                          color: Colors.amber.withValues(alpha: 0.8),
                        ),
                      ),
                    if (pendingRevisionsCount > 0)
                      Expanded(
                        flex: pendingRevisionsCount,
                        child: Container(
                          color: Colors.orange.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            gapH12,
          ],
        );
      },
    );
  }
}
