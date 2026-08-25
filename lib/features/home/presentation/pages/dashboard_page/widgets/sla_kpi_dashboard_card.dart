import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/kpi_period_filter_selector.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/stats_card.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/dashboard_kpis/dashboard_kpis_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class SlaKpiDashboardCard extends StatelessWidget {
  const SlaKpiDashboardCard({super.key});

  static String formatDurationMinutes(double minutes) {
    if (minutes <= 0) return '0m'.hardcoded;
    if (minutes < 60) {
      return '${minutes.round()}m'.hardcoded;
    }
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).round();
    if (remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m'.hardcoded;
    }
    return '${hours}h'.hardcoded;
  }

  Color _getDeliveryRateColor(double rate, int completedCount) {
    if (completedCount == 0) return Colors.blue;
    if (rate >= 90.0) return Colors.green;
    if (rate >= 75.0) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final workOrders = context.select<WorkOrdersCubit, List<dynamic>>(
      (cubit) => cubit.state.workOrders,
    );

    return BlocConsumer<DashboardKpisCubit, DashboardKpisState>(
      listenWhen: (prev, curr) => false,
      listener: (context, state) {},
      builder: (context, kpisState) {
        final metrics = kpisState.metrics;
        final deliveryColor = _getDeliveryRateColor(
          metrics.deliveryRate,
          metrics.completedCount,
        );

        final cards = [
          StatsCard(
            title: metrics.completedCount > 0
                ? '${metrics.completedWithinSlaCount}/${metrics.completedCount} no prazo'.hardcoded
                : 'Sem OS concluídas'.hardcoded,
            value: metrics.completedCount > 0
                ? '${metrics.deliveryRate.toStringAsFixed(1)}%'
                : '--',
            icon: const PlatformIcon(
              materialIcon: Icons.verified_outlined,
              cupertinoIcon: CupertinoIcons.checkmark_seal,
            ),
            color: deliveryColor,
          ),
          StatsCard(
            title: 'Tempo médio de resolução'.hardcoded,
            value: metrics.completedCount > 0
                ? formatDurationMinutes(metrics.mttrMinutes)
                : '--',
            icon: const PlatformIcon(
              materialIcon: Icons.timer_outlined,
              cupertinoIcon: CupertinoIcons.timer,
            ),
            color: Colors.blue,
          ),
          StatsCard(
            title: metrics.completedCount > 0
                ? '${metrics.slaBreachedCount} fora do prazo'.hardcoded
                : 'Sem quebras'.hardcoded,
            value: metrics.completedCount > 0
                ? '${metrics.breachRate.toStringAsFixed(1)}%'
                : '0%',
            icon: const PlatformIcon(
              materialIcon: Icons.warning_amber_rounded,
              cupertinoIcon: CupertinoIcons.exclamationmark_triangle,
            ),
            color: metrics.slaBreachedCount > 0 ? Colors.orange : Colors.green,
          ),
          StatsCard(
            title: 'Em aberto fora do prazo'.hardcoded,
            value: metrics.delayedCount.toString(),
            icon: const PlatformIcon(
              materialIcon: Icons.alarm_off_outlined,
              cupertinoIcon: CupertinoIcons.clock_fill,
            ),
            color: metrics.delayedCount > 0 ? Colors.red : Colors.teal,
          ),
        ];

        final isPhone =
            context.screenType == ScreenType.compact ||
            context.screenType == ScreenType.phone;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            gapH8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BaseText.title(
                    'INDICADORES DE SLA & DESEMPENHO'.hardcoded,
                  ),
                ),
                KpiPeriodFilterSelector(
                  selectedPeriod: kpisState.selectedPeriod,
                  onPeriodSelected: (period) {
                    final cubit = context.read<WorkOrdersCubit>();
                    context.read<DashboardKpisCubit>().changePeriod(
                          period,
                          cubit.state.workOrders,
                        );
                  },
                ),
              ],
            ),
            gapH12,
            if (isPhone)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: Sizes.p8,
                crossAxisSpacing: Sizes.p8,
                childAspectRatio: 1.25,
                children: cards,
              )
            else
              Row(
                children: cards
                    .map(
                      (card) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: Sizes.p8),
                          child: card,
                        ),
                      ),
                    )
                    .toList(),
              ),
            gapH16,
          ],
        );
      },
    );
  }
}
