enum IntervalUnit {
  days('days'),
  weeks('weeks'),
  months('months'),
  years('years');

  const IntervalUnit(this.code);
  final String code;

  static IntervalUnit fromCode(String code) {
    for (final val in IntervalUnit.values) {
      if (val.code == code) return val;
    }
    return IntervalUnit.months;
  }
}
