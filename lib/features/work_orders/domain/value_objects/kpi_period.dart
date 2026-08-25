enum KpiPeriod {
  allTime,
  last7Days,
  last30Days,
  thisMonth;

  DateTime? getStartDate([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    switch (this) {
      case KpiPeriod.allTime:
        return null;
      case KpiPeriod.last7Days:
        return now.subtract(const Duration(days: 7));
      case KpiPeriod.last30Days:
        return now.subtract(const Duration(days: 30));
      case KpiPeriod.thisMonth:
        return DateTime(now.year, now.month, 1);
    }
  }

  bool isWithinPeriod(DateTime date, [DateTime? reference]) {
    final startDate = getStartDate(reference);
    if (startDate == null) return true;
    return !date.isBefore(startDate);
  }
}
