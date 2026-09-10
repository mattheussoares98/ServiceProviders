/// Supported file extensions for file picking and validation.
enum FileExtension {
  pdf('pdf'),
  docx('docx'),
  xlsx('xlsx'),
  jpg('jpg'),
  jpeg('jpeg'),
  png('png'),
  webp('webp'),
  heic('heic'),
  mp4('mp4'),
  mov('mov');

  const FileExtension(this.value);
  final String value;

  static const Set<FileExtension> images = {jpg, jpeg, png, webp, heic};
  static const Set<FileExtension> documents = {pdf, docx, xlsx};
  static const Set<FileExtension> videos = {mp4, mov};

  static FileExtension? fromExtension(String ext) {
    final clean = ext.toLowerCase().replaceFirst('.', '');
    for (final val in FileExtension.values) {
      if (val.value == clean) return val;
    }
    return null;
  }
}
