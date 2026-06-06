enum FileType {
  image('image'),
  pdf('pdf'),
  document('document'),
  signature('signature');

  const FileType(this.code);
  final String code;

  static FileType fromCode(String code) {
    for (final val in FileType.values) {
      if (val.code == code) return val;
    }
    return FileType.document;
  }
}
