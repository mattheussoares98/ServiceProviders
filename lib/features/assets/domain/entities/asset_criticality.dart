enum AssetCriticality {
  low('low'),
  medium('medium'),
  high('high'),
  missionCritical('mission_critical');

  const AssetCriticality(this.code);
  final String code;

  static AssetCriticality fromCode(String code) {
    for (final val in AssetCriticality.values) {
      if (val.code == code) return val;
    }
    return AssetCriticality.medium;
  }
}
