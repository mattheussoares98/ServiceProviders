enum PauseEventType {
  pause('pause'),
  completion('completion');

  const PauseEventType(this.value);
  final String value;

  static PauseEventType fromValue(String value) {
    for (final val in PauseEventType.values) {
      if (val.value == value) return val;
    }
    return PauseEventType.pause;
  }
}
