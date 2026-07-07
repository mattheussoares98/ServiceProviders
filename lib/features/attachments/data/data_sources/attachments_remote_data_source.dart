import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/http/http_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/constants/api_endpoints.dart';
import 'package:o_jogo_da_obra/core/data/handlers/api_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';

abstract interface class AttachmentsRemoteDataSource {
  /// Requests a time-limited presigned PUT URL from the backend Edge Function.
  ///
  /// [objectKey] must follow the convention built by [StorageClient.buildObjectKey].
  FutureData<PresignedUrlResponse> getPresignedUploadUrl(String objectKey);

  /// Saves [remoteUrl] on the attachment record after a successful R2 upload.
  FutureBool confirmUpload({
    required String attachmentId,
    required String remoteUrl,
  });

  /// Fetches all non-deleted attachments for a given work order from the API.
  FutureList<AttachmentResponseModel> getAttachmentsByWorkOrder(
    String workOrderId,
  );
}

@LazySingleton(as: AttachmentsRemoteDataSource)
final class AttachmentsRemoteDataSourceImpl
    implements AttachmentsRemoteDataSource {
  const AttachmentsRemoteDataSourceImpl({required HttpClient httpClient})
    : _httpClient = httpClient;

  final HttpClient _httpClient;

  @override
  FutureData<PresignedUrlResponse> getPresignedUploadUrl(String objectKey) =>
      ApiHandler.call(
        () => _httpClient.post<MapDynamic>(
          ApiEndpoints.presignedUploadUrl,
          data: {'object_key': objectKey},
        ),
        fromJson: (json) => PresignedUrlResponse(
          uploadUrl: json['upload_url'] as String,
          fileKey: json['file_key'] as String,
        ),
      );

  @override
  FutureBool confirmUpload({
    required String attachmentId,
    required String remoteUrl,
  }) => ApiHandler.staticCall(
    () => _httpClient.patch<void>(
      '${ApiEndpoints.attachments}/$attachmentId/confirm',
      data: {'remote_url': remoteUrl},
    ),
    staticData: true,
  );

  @override
  FutureList<AttachmentResponseModel> getAttachmentsByWorkOrder(
    String workOrderId,
  ) => ApiHandler.call<List<AttachmentResponseModel>, AttachmentResponseModel>(
    () => _httpClient.get<MapDynamic>(
      ApiEndpoints.attachments,
      queryParameters: {'work_order_id': workOrderId},
    ),
    fromJson: AttachmentResponseModel.fromJson,
  );
}
