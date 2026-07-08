import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/value_objects/attachment_file_validator.dart';

void main() {
  group('AttachmentFileValidator.validate', () {
    test('should return AttachmentValid when file extension is allowed and size is within limit', () {
      // Images
      expect(
        AttachmentFileValidator.validate('jpg', 20 * 1024 * 1024),
        isA<AttachmentValid>(),
      );
      expect(
        AttachmentFileValidator.validate('PNG', 10 * 1024 * 1024), // case insensitivity check
        isA<AttachmentValid>(),
      );

      // Videos
      expect(
        AttachmentFileValidator.validate('mp4', 100 * 1024 * 1024),
        isA<AttachmentValid>(),
      );

      // PDF
      expect(
        AttachmentFileValidator.validate('pdf', 10 * 1024 * 1024),
        isA<AttachmentValid>(),
      );

      // Docs
      expect(
        AttachmentFileValidator.validate('docx', 5 * 1024 * 1024),
        isA<AttachmentValid>(),
      );
      expect(
        AttachmentFileValidator.validate('xlsx', 1024),
        isA<AttachmentValid>(),
      );
    });

    test('should return AttachmentInvalidType when extension is not supported', () {
      final result = AttachmentFileValidator.validate('txt', 100);
      expect(result, isA<AttachmentInvalidType>());
      expect((result as AttachmentInvalidType).extension, 'txt');

      final result2 = AttachmentFileValidator.validate('', 100);
      expect(result2, isA<AttachmentInvalidType>());
    });

    test('should return AttachmentInvalidSize when image exceeds 20MB', () {
      const maxBytes = 20 * 1024 * 1024;
      final result = AttachmentFileValidator.validate('jpg', maxBytes + 1);
      expect(result, isA<AttachmentInvalidSize>());
      expect((result as AttachmentInvalidSize).maxBytes, maxBytes);
      expect(result.actualBytes, maxBytes + 1);
    });

    test('should return AttachmentInvalidSize when video exceeds 100MB', () {
      const maxBytes = 100 * 1024 * 1024;
      final result = AttachmentFileValidator.validate('mp4', maxBytes + 1);
      expect(result, isA<AttachmentInvalidSize>());
      expect((result as AttachmentInvalidSize).maxBytes, maxBytes);
      expect(result.actualBytes, maxBytes + 1);
    });

    test('should return AttachmentInvalidSize when PDF exceeds 10MB', () {
      const maxBytes = 10 * 1024 * 1024;
      final result = AttachmentFileValidator.validate('pdf', maxBytes + 1);
      expect(result, isA<AttachmentInvalidSize>());
      expect((result as AttachmentInvalidSize).maxBytes, maxBytes);
      expect(result.actualBytes, maxBytes + 1);
    });

    test('should return AttachmentInvalidSize when DOCX/XLSX exceeds 5MB', () {
      const maxBytes = 5 * 1024 * 1024;
      final result = AttachmentFileValidator.validate('docx', maxBytes + 1);
      expect(result, isA<AttachmentInvalidSize>());
      expect((result as AttachmentInvalidSize).maxBytes, maxBytes);
      expect(result.actualBytes, maxBytes + 1);
    });
  });
}