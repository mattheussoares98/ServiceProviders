enum ChecklistItemType {
  boolean('boolean'),
  BaseText('text'),
  number('number'),
  photo('photo'),
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
