/// Result type returned by [AttachmentFileValidator.validate].
sealed class AttachmentValidationResult {
  const AttachmentValidationResult();
}

/// The file passed all validation rules and may be processed.
final class AttachmentValid extends AttachmentValidationResult {
  const AttachmentValid();
}

/// The file exceeds the allowed size limit for its type.
final class AttachmentInvalidSize extends AttachmentValidationResult {
  const AttachmentInvalidSize({
    required this.maxBytes,
    required this.actualBytes,
  });

  final int maxBytes;
  final int actualBytes;
}

/// The file extension is not in the allow-list.
final class AttachmentInvalidType extends AttachmentValidationResult {
  const AttachmentInvalidType({required this.extension});

  final String extension;
}

/// Stateless validator for attachment file extension and size.
///
/// Size limits are checked against the **original** file before any compression.
/// Compression is applied afterwards only for images and videos.
abstract final class AttachmentFileValidator {
  // Original-file size limits (before compression).
  static const _maxImageBytes = 20 * 1024 * 1024; // 20 MB
  static const _maxVideoBytes = 500 * 1024 * 1024; // 100 MB
  static const _maxPdfBytes = 10 * 1024 * 1024; // 10 MB
  static const _maxDocumentBytes = 5 * 1024 * 1024; //  5 MB

  static const _allowedExtensions = {
    'jpg', 'jpeg', 'png', 'webp', 'heic', // images
    'mp4', 'mov', // videos
    'pdf', // PDF
    'docx', // Word
    'xlsx', // Excel
  };

  /// Validates [extension] (without leading dot) and [sizeBytes].
  ///
  /// Returns [AttachmentValid] when both are within bounds,
  /// [AttachmentInvalidType] for unsupported extensions, or
  /// [AttachmentInvalidSize] when the file exceeds the type limit.
  static AttachmentValidationResult validate(String extension, int sizeBytes) {
    final ext = extension.toLowerCase();

    if (!_allowedExtensions.contains(ext)) {
      return AttachmentInvalidType(extension: ext);
    }

    final maxBytes = switch (ext) {
      'pdf' => _maxPdfBytes,
      'docx' || 'xlsx' => _maxDocumentBytes,
      'mp4' || 'mov' => _maxVideoBytes,
      _ => _maxImageBytes,
    };

    if (sizeBytes > maxBytes) {
      return AttachmentInvalidSize(maxBytes: maxBytes, actualBytes: sizeBytes);
    }

    return const AttachmentValid();
  }
}
