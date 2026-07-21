enum PauseResponsibility {
  provider('provider', 'Prestador'),
  contractor('contractor', 'Contratante'),
  shared('shared', 'Compartilhada');

  const PauseResponsibility(this.value, this.label);
  final String value;
  final String label;

  static PauseResponsibility fromValue(String value) {
    for (final val in PauseResponsibility.values) {
      if (val.value == value) return val;
    }
    return PauseResponsibility.provider;
  }
}
