import 'package:flutter/foundation.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';

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
  // Default fallback original-file size limits (before compression).
  static const _defaultImageBytes =
      (kIsWeb ? 2 : 20) * 1024 * 1024; // 2MB web && 20MB mobile
  static const _defaultVideoBytes =
      (kIsWeb ? 10 : 500) * 1024 * 1024; // 10MB web && 500MB mobile
  static const _defaultPdfBytes = 10 * 1024 * 1024; // 10 MB
  static const _defaultDocumentBytes = 5 * 1024 * 1024; // 5 MB

  static const _allowedExtensions = {
    'jpg', 'jpeg', 'png', 'webp', 'heic', // images
    'mp4', 'mov', // videos
    'pdf', // PDF
    'docx', // Word
    'xlsx', // Excel
  };

  /// Validates [extension] (without leading dot) and [sizeBytes].
  ///
  /// If [parameters] is provided, uses its configured limits; otherwise
  /// falls back to defaults.
  ///
  /// Returns [AttachmentValid] when both are within bounds,
  /// [AttachmentInvalidType] for unsupported extensions, or
  /// [AttachmentInvalidSize] when the file exceeds the type limit.
  static AttachmentValidationResult validate(
    String extension,
    int sizeBytes, {
    CompanyParameterEntity? parameters,
  }) {
    final ext = extension.toLowerCase();

    if (!_allowedExtensions.contains(ext)) {
      return AttachmentInvalidType(extension: ext);
    }

    final maxBytes = switch (ext) {
      'pdf' => parameters?.maxPdfSizeBytes ?? _defaultPdfBytes,
      'docx' || 'xlsx' =>
        parameters?.maxDocumentSizeBytes ?? _defaultDocumentBytes,
      'mp4' || 'mov' =>
        kIsWeb
            ? (10 * 1024 * 1024)
            : (parameters?.maxVideoSizeBytes ?? _defaultVideoBytes),
      _ =>
        kIsWeb
            ? (2 * 1024 * 1024)
            : (parameters?.maxImageSizeBytes ?? _defaultImageBytes),
    };

    if (sizeBytes > maxBytes) {
      return AttachmentInvalidSize(maxBytes: maxBytes, actualBytes: sizeBytes);
    }

    return const AttachmentValid();
  }
}

