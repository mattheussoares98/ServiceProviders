enum Frequency {
  daily('daily'),
  weekly('weekly'),
  biweekly('biweekly'),
  monthly('monthly'),
  quarterly('quarterly'),
  semiannual('semiannual'),
  annual('annual');

  const Frequency(this.code);
  final String code;

  static Frequency fromCode(String code) {
    for (final val in Frequency.values) {
      if (val.code == code) return val;
    }
    return Frequency.monthly;
  }
}
