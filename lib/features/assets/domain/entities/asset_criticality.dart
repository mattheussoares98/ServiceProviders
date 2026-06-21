enum AssetCriticality {
  low('low', 'Baixa'),
  medium('medium', 'Média'),
  high('high', 'Alta'),
  missionCritical('mission_critical', 'Crítica');

  const AssetCriticality(this.code, this.label);
  final String code;
  final String label;

  static AssetCriticality fromCode(String code) {
    for (final val in AssetCriticality.values) {
      if (val.code == code) return val;
    }
    return AssetCriticality.medium;
  }
}
