enum ChecklistItemType {
  boolean('boolean'),
  text('text'),
  number('number'),
  photo('photo'),
  documentation('documentation'),
  selection('selection');

  const ChecklistItemType(this.code);
  final String code;

  static ChecklistItemType fromCode(String code) {
    for (final val in ChecklistItemType.values) {
      if (val.code == code) return val;
    }
    return ChecklistItemType.boolean;
  }
}
