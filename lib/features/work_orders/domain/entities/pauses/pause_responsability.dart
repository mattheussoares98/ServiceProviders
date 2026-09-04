enum PauseResponsibility {
  provider('provider'),
  contractor('contractor'),
  shared('shared');

  const PauseResponsibility(this.value);
  final String value;

  static PauseResponsibility fromValue(String value) {
    for (final val in PauseResponsibility.values) {
      if (val.value == value) return val;
    }
    return PauseResponsibility.provider;
  }
}
