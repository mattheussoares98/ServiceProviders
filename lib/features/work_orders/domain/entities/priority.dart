enum Priority {
  low('low', 'Baixa'),
  medium('medium', 'Média'),
  high('high', 'Alta'),
  critical('critical', 'Crítica');

  const Priority(this.code, this.label);
  final String code;
  final String label;

  static Priority fromCode(String code) {
    for (final val in Priority.values) {
      if (val.code == code) return val;
    }
    return Priority.medium;
  }
}
