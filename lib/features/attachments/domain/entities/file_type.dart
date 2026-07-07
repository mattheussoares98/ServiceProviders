enum FileType {
  image('image'),
  video('video'),
  pdf('pdf'),
  document('document'),
  spreadsheet('spreadsheet'),
  signature('signature');

  const FileType(this.code);
  final String code;

  static FileType fromCode(String code) {
    for (final val in FileType.values) {
      if (val.code == code) return val;
    }
    return FileType.document;
  }

  static FileType fromExtension(String ext) => switch (ext.toLowerCase()) {
    'jpg' || 'jpeg' || 'png' || 'webp' || 'heic' => FileType.image,
    'mp4' || 'mov' => FileType.video,
    'pdf' => FileType.pdf,
    'docx' => FileType.document,
    'xlsx' => FileType.spreadsheet,
    _ => FileType.document,
  };
}
