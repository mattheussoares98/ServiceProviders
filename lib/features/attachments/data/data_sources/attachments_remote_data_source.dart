import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AttachmentsRemoteDataSource {
  /// Requests a time-limited presigned PUT URL from the backend Edge Function.
  ///
  /// [objectKey] must follow the convention built by [StorageClient.buildObjectKey].
  FutureData<PresignedUrlResponse> getPresignedUploadUrl(String objectKey);

  /// Saves the attachment record on the remote database after a successful R2 upload.
  FutureBool confirmUpload(AttachmentResponseModel attachment);

  /// Fetches all non-deleted attachments for a given work order from the database.
  FutureList<AttachmentResponseModel> getAttachmentsByWorkOrder(
    String workOrderId,
  );

  /// Deletes an attachment by ID from the remote database.
  FutureBool deleteAttachment(String id);
}

@LazySingleton(as: AttachmentsRemoteDataSource)
final class AttachmentsRemoteDataSourceImpl
    implements AttachmentsRemoteDataSource {
  const AttachmentsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureData<PresignedUrlResponse> getPresignedUploadUrl(String objectKey) =>
      SupabaseHandler.call(() async {
        final response = await _database.invokeFunction(
          'generate_presigned_url',
          method: HttpMethod.post,
          body: {'object_key': objectKey},
        );
        final data = response.data as MapDynamic;
        return PresignedUrlResponse(
          uploadUrl: data['upload_url'] as String,
          fileKey: data['file_key'] as String,
        );
      });

  @override
  FutureBool confirmUpload(AttachmentResponseModel attachment) =>
      SupabaseHandler.call(() async {
        await _database.upsert(
          table: 'attachments',
          values: attachment.toJson(),
        );
        return true;
      });

  @override
  FutureList<AttachmentResponseModel> getAttachmentsByWorkOrder(
    String workOrderId,
  ) => SupabaseHandler.call(() async {
    final response = await _database.selectList(
      table: 'attachments',
      filters: [
        SupabaseFilter.eq('work_order_id', workOrderId),
        SupabaseFilter.isFilter('deleted_at', null),
      ],
    );
    return response.map(AttachmentResponseModel.fromJson).toList();
  });

  @override
  FutureBool deleteAttachment(String id) => SupabaseHandler.call(() async {
    await _database.update(
      table: 'attachments',
      values: <String, dynamic>{'deleted_at': DateTime.now().toIso8601String()},
      filters: [SupabaseFilter.eq('id', id)],
    );
    return true;
  });
}
