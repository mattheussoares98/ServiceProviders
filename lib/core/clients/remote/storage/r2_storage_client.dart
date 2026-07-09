import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/constants/api_endpoints.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

/// Cloudflare R2 implementation of [StorageClient].
///
/// Uses a **dedicated** Dio instance (not the shared [HttpClient]) so that
/// the app's auth interceptor is NOT attached — R2 presigned URLs are
/// self-authenticating and must not carry the backend JWT.
@LazySingleton(as: StorageClient)
final class R2StorageClient implements StorageClient {
  R2StorageClient()
    : _dio =
          Dio(); //TODO is it using get it? Shouldn't we use the HttpClientModule?

  @visibleForTesting
  R2StorageClient.withDio(Dio dio) : _dio = dio;
  // A fresh Dio without any interceptors — presigned URLs are self-authenticating.
  final Dio _dio;

  @override
  FutureData<PresignedUrlResponse> getPresignedUploadUrl(String objectKey) {
    return ErrorHandler.execute(() async {
      final response = await _dio.post<MapDynamic>(
        ApiEndpoints.presignedUploadUrl,
        data: {'object_key': objectKey},
      );

      final body = response.data;
      if (body == null) {
        return FailureState(message: 'Resposta vazia do servidor'.hardcoded);
      }

      return SuccessState(
        data: PresignedUrlResponse(
          uploadUrl: body['upload_url'] as String,
          fileKey: body['file_key'] as String,
        ),
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
      final file = File(filePath);
      final fileSize = await file.length();
      final stream = file.openRead();

      await _dio.put<void>(
        presignedUrl,
        data: stream,
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
