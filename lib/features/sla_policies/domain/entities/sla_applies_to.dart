enum SlaAppliesTo {
  provider('provider', 'Prestador'),
  contractor('contractor', 'Contratante'),
  both('both', 'Ambos');

  const SlaAppliesTo(this.value, this.label);
  final String value;
  final String label;

  static SlaAppliesTo fromValue(String value) {
    for (final val in SlaAppliesTo.values) {
      if (val.value == value) return val;
    }
    return SlaAppliesTo.both;
  }
}
