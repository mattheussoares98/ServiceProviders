import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

/// Represents the response from a presigned-URL generation request.
///
/// [uploadUrl]  — the time-limited PUT URL to upload the file directly to R2.
/// [fileKey]    — the object key stored in R2 (used to build the final public URL).
///                Format: `attachments/{companyId}/{workOrderId}/{uuid}.{ext}`
class PresignedUrlResponse {
  const PresignedUrlResponse({
    required this.uploadUrl,
    required this.fileKey,
    required this.publicUrl,
  });

  final String uploadUrl;
  final String fileKey;
  final String publicUrl;
}

/// Abstract client for cloud file storage operations.
///
/// The implementation uses Cloudflare R2 with the AWS presigned URL pattern:
///   1. App requests a presigned PUT URL from a Supabase Edge Function.
///   2. App uploads the file bytes directly to R2 using that URL.
///   3. App confirms the upload by saving `fileKey` to the backend.
///
/// Credentials are NEVER held in the Flutter app — they live only in the
/// Edge Function as Supabase secrets.
abstract interface class StorageClient {
  /// Requests a time-limited presigned PUT URL from the backend Edge Function.
  ///
  /// [objectKey] must follow the convention:
  ///   `attachments/{companyId}/{workOrderId}/{uuid}.{extension}`
  FutureData<PresignedUrlResponse> getPresignedUploadUrl(String objectKey);

  /// Uploads the file at [filePath] directly to R2 using the [presignedUrl].
  ///
  /// [mimeType] sets the Content-Type header (e.g. `'image/webp'`, `'application/pdf'`).
  /// Returns the final public URL of the uploaded object on success.
  FutureString uploadFile({
    required String presignedUrl,
    required String filePath,
    required String mimeType,
  });

  /// Builds the R2 object key for an attachment.
  ///
  /// This is a pure helper — it does not make any network call.
  static String buildObjectKey({
    required String companyId,
    required String workOrderId,
    required String uuid,
    required String extension,
  }) => 'attachments/$companyId/$workOrderId/$uuid.$extension';
}
