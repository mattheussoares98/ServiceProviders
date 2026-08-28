import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/dashboard_page/widgets/stats_card.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/dashboard_kpis/dashboard_kpis_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/formatted_duration_timer_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

part './kpi_date_range_slider.dart';

class SlaKpiDashboardCard extends StatelessWidget {
  const SlaKpiDashboardCard({super.key});

  Color _getDeliveryRateColor(double rate, int completedCount) {
    if (completedCount == 0) return Colors.blue;
    if (rate >= 90.0) return Colors.green;
    if (rate >= 75.0) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final workOrders = context.select<WorkOrdersCubit, List<WorkOrderEntity>>(
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
                ? '${metrics.completedWithinSlaCount}/${metrics.completedCount} no prazo'
                      .hardcoded
                : 'Sem OS concluídas'.hardcoded,
            value: metrics.completedCount > 0
                ? '${metrics.deliveryRate.toString().toBrazilianNumber()}%'
                : '--',
            icon: const PlatformIcon(
              materialIcon: Icons.verified_outlined,
              cupertinoIcon: CupertinoIcons.checkmark_seal,
            ),
            color: deliveryColor,
          ),
          StatsCard(
            title: 'Tempo médio de resolução'.hardcoded,
            valueWidget: metrics.completedCount > 0
                ? FormattedDurationTimerText(
                    initialAccumulatedSeconds: (metrics.mttrMinutes * 60)
                        .round(),
                    isRunning: false,
                    color: Colors.blue,
                    fontWeight: FontWeight.w900,
                  )
                : BaseText.headline(
                    '--',
                    fontWeight: FontWeight.w900,
                    color: Colors.blue,
                  ),
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
                ? '${metrics.breachRate.toString().toBrazilianNumber()}%'
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
            BaseText.title('INDICADORES DE SLA & DESEMPENHO'.hardcoded),
            gapH8,
            KpiDateRangeSlider(
              startDate: kpisState.startDate,
              endDate: kpisState.endDate,
              onDateRangeChanged: (start, end) {
                context.read<DashboardKpisCubit>().changeDateRange(
                  start,
                  end,
                  workOrders,
                );
              },
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
