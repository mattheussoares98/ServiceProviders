enum AssetStatus {
  active('active', 'Ativo'),
  inactive('inactive', 'Inativo'),
  decommissioned('decommissioned', 'Desativado');

  const AssetStatus(this.code, this.label);
  final String code;
  final String label;

  static AssetStatus fromCode(String code) {
    for (final val in AssetStatus.values) {
      if (val.code == code) return val;
    }
    return AssetStatus.active;
  }
}
