enum UploadStatus {
  pending('pending'),
  uploaded('uploaded'),
  failed('failed');

  const UploadStatus(this.code);
  final String code;

  static UploadStatus fromCode(String code) {
    for (final val in UploadStatus.values) {
      if (val.code == code) return val;
    }
    return UploadStatus.pending;
  }
}
