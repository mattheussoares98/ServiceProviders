import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/http/http_client.dart'
    show HttpClient;
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show HttpMethod;

/// Cloudflare R2 implementation of [StorageClient].
///
/// Uses a **dedicated** Dio instance (not the shared [HttpClient]) so that
/// the app's auth interceptor is NOT attached — R2 presigned URLs are
/// self-authenticating and must not carry the backend JWT.
@LazySingleton(as: StorageClient)
final class R2StorageClient implements StorageClient {
  R2StorageClient({
    required FileService fileService,
    required SupabaseDatabaseClient database,
    @visibleForTesting Dio? dio,
  })  : _fileService = fileService,
        _database = database,
        _dio = dio ?? Dio();

  // A fresh Dio without any interceptors — presigned URLs are self-authenticating.
  final Dio _dio;
  final FileService _fileService;
  final SupabaseDatabaseClient _database;

  @override
  FutureData<PresignedUrlResponse> getPresignedUploadUrl(String objectKey) {
    return SupabaseHandler.call(() async {
      final response = await _database.invokeFunction(
        'generate_presigned_url',
        method: HttpMethod.post,
        body: {'object_key': objectKey},
      );

      final data = response.data as MapDynamic;
      return PresignedUrlResponse(
        uploadUrl: data['upload_url'] as String,
        fileKey: data['file_key'] as String,
        publicUrl: data['public_url'] as String? ?? '',
      );
    });
  }

  @override
  FutureString uploadFile({
    required String presignedUrl,
    required String filePath,
    required String mimeType,
  }) {
    return ErrorHandler.execute(() async {
      final bytes = await _fileService.readFileAsBytes(filePath);
      final fileSize = bytes.length;

      await _dio.put<void>(
        presignedUrl,
        data: bytes,
        options: Options(
          headers: {
            Headers.contentTypeHeader: mimeType,
            Headers.contentLengthHeader: fileSize,
          },
          // Disable response validation — R2 returns 200 with an empty body,
          // which Dio might misinterpret without this.
          responseType: ResponseType.bytes,
        ),
      );

      // Derive the public URL from the presigned URL host + file key.
      // The presigned URL contains query params after the path — we only
      // keep the base: https://{bucket}.r2.dev/{fileKey}
      final uri = Uri.parse(presignedUrl);
      final publicUrl =
          '${uri.scheme}://${uri.host}/${uri.pathSegments.join('/')}';

      return SuccessState(data: publicUrl);
    });
  }
}
