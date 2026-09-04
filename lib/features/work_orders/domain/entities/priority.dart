enum Priority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const Priority(this.code);
  final String code;

  static Priority fromCode(String code) {
    for (final val in Priority.values) {
      if (val.code == code) return val;
    }
    return Priority.medium;
  }
}
