part of 'sla_kpi_dashboard_card.dart';

class KpiDateRangeSlider extends HookWidget {
  const KpiDateRangeSlider({
    super.key,
    this.startDate,
    this.endDate,
    this.onDateRangeChanged,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime start, DateTime end)? onDateRangeChanged;

  @override
  Widget build(BuildContext context) {
    final workOrders = context.select<WorkOrdersCubit, List<WorkOrderEntity>>(
      (cubit) => cubit.state.workOrders,
    );

    final isDark = context.theme.brightness == Brightness.dark;
    final activeOrders = useMemoized(
      () => workOrders.where((wo) => wo.deletedAt == null).toList(),
      [workOrders],
    );

    final (minDate, maxDate) = useMemoized(() {
      if (activeOrders.isEmpty) {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month - 1);
        final end = DateTime(now.year, now.month, now.day);
        return (start, end);
      }

      var earliest = activeOrders.first.createdAt;
      var latest =
          activeOrders.first.completedAt ?? activeOrders.first.createdAt;

      for (final wo in activeOrders) {
        if (wo.createdAt.isBefore(earliest)) {
          earliest = wo.createdAt;
        }
        final orderEnd = wo.completedAt ?? wo.createdAt;
        if (orderEnd.isAfter(latest)) {
          latest = orderEnd;
        }
      }

      final start = DateTime(earliest.year, earliest.month, earliest.day);
      var end = DateTime(latest.year, latest.month, latest.day);

      if (!end.isAfter(start)) {
        end = start.add(const Duration(days: 1));
      }

      return (start, end);
    }, [activeOrders]);

    final totalDays = max(1, maxDate.difference(minDate).inDays);

    final initialStartOffset = startDate != null
        ? startDate!.difference(minDate).inDays.clamp(0, totalDays).toDouble()
        : 0.0;
    final initialEndOffset = endDate != null
        ? endDate!.difference(minDate).inDays.clamp(0, totalDays).toDouble()
        : totalDays.toDouble();

    final currentRange = useState<RangeValues>(
      RangeValues(
        initialStartOffset,
        initialEndOffset > initialStartOffset
            ? initialEndOffset
            : totalDays.toDouble(),
      ),
    );

    useEffect(() {
      final startOffset = startDate != null
          ? startDate!.difference(minDate).inDays.clamp(0, totalDays).toDouble()
          : 0.0;
      final endOffset = endDate != null
          ? endDate!.difference(minDate).inDays.clamp(0, totalDays).toDouble()
          : totalDays.toDouble();

      currentRange.value = RangeValues(
        startOffset,
        endOffset > startOffset ? endOffset : totalDays.toDouble(),
      );
      return null;
    }, [startDate, endDate, minDate, maxDate, totalDays]);

    final selectedStart = minDate.add(
      Duration(days: currentRange.value.start.round()),
    );
    final selectedEnd = minDate.add(
      Duration(days: currentRange.value.end.round()),
    );

    final hasOrders = activeOrders.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p12,
        vertical: Sizes.p8,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlatformIcon(
                      materialIcon: Icons.date_range_outlined,
                      cupertinoIcon: CupertinoIcons.calendar,
                      size: Sizes.p16,
                      color: context.theme.colorScheme.primary,
                    ),
                    gapW8,
                    Expanded(
                      child: BaseText.bodySmall(
                        'Período'.hardcoded,
                        color: context.theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              gapW8,
              Flexible(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.p8,
                    vertical: Sizes.p4,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(Sizes.p8),
                  ),
                  child: BaseText.bodySmall(
                    '${selectedStart.formatDate()} - ${selectedEnd.formatDate()}',
                    color: context.theme.primaryColor,
                    textAlign: .center,
                    fontWeight: .bold,
                  ),
                ),
              ),
            ],
          ),
          gapH4,
          RangeSlider(
            values: currentRange.value,
            max: totalDays.toDouble(),
            divisions: totalDays > 1 ? totalDays : null,
            padding: const .symmetric(vertical: Sizes.p8),
            onChanged: hasOrders
                ? (values) {
                    currentRange.value = values;
                  }
                : null,
            onChangeEnd: hasOrders
                ? (values) {
                    final finalStart = minDate.add(
                      Duration(days: values.start.round()),
                    );
                    final finalEnd = minDate.add(
                      Duration(days: values.end.round()),
                    );
                    onDateRangeChanged?.call(finalStart, finalEnd);
                    context.read<DashboardKpisCubit>().changeDateRange(
                      finalStart,
                      finalEnd,
                      workOrders,
                    );
                  }
                : null,
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Expanded(
                child: BaseText.bodySmall(
                  minDate.formatDate(),
                  color: context.theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              gapW8,
              Expanded(
                child: BaseText.bodySmall(
                  maxDate.formatDate(),
                  textAlign: .right,
                  color: context.theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
