enum SlaAppliesTo {
  provider('provider'),
  contractor('contractor'),
  both('both');

  const SlaAppliesTo(this.value);
  final String value;

  static SlaAppliesTo fromValue(String value) {
    for (final val in SlaAppliesTo.values) {
      if (val.value == value) return val;
    }
    return SlaAppliesTo.both;
  }
}
