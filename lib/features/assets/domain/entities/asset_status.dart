enum AssetStatus {
  active('active'),
  inactive('inactive'),
  decommissioned('decommissioned');

  const AssetStatus(this.code);
  final String code;

  static AssetStatus fromCode(String code) {
    for (final val in AssetStatus.values) {
      if (val.code == code) return val;
    }
    return AssetStatus.active;
  }
}
