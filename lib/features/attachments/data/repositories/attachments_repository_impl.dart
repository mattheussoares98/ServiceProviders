import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_local_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/value_objects/attachment_file_validator.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

@LazySingleton(as: AttachmentsRepository)
final class AttachmentsRepositoryImpl implements AttachmentsRepository {
  AttachmentsRepositoryImpl({
    required InternetClient internet,
    required FileService fileService,
    required StorageClient storageClient,
    required AttachmentsRemoteDataSource remoteDataSource,
    required AttachmentsLocalDataSource localDataSource,
  }) : _internet = internet,
       _fileService = fileService,
       _storageClient = storageClient,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final FileService _fileService;
  final StorageClient _storageClient;
  final AttachmentsRemoteDataSource _remoteDataSource;
  final AttachmentsLocalDataSource _localDataSource;

  // ──────────────────────────────────────────
  // Standard CRUD
  // ──────────────────────────────────────────

  @override
  FutureList<AttachmentEntity> getAttachmentsByWorkOrder(
    String workOrderId,
  ) async {
    // When online, sync remote attachments (from other users/devices) into the
    // local DB so they are visible offline and to the current user.
    if (_internet.isConnected) {
      final remoteResult = await _remoteDataSource.getAttachmentsByWorkOrder(
        workOrderId,
      );
      if (remoteResult is SuccessState<List<AttachmentResponseModel>>) {
        await Future.wait([
          for (final model in remoteResult.data ?? <AttachmentResponseModel>[])
            _localDataSource.saveAttachment(model),
        ]);
      }
    }

    // Always return from local: includes pending (not uploaded yet) +
    // uploaded (own device or synced from remote).
    return RepositoryHandler.fetchFromLocalAndMapList<
      AttachmentResponseModel,
      AttachmentEntity
    >(
      localCallback: () =>
          _localDataSource.getAttachmentsByWorkOrder(workOrderId),
    );
  }

  @override
  FutureBool createAttachment(AttachmentEntity attachment) => _localDataSource
      .saveAttachment(AttachmentResponseModel.fromEntity(attachment));

  @override
  FutureBool deleteAttachment(String id) async {
    final localResult = await _localDataSource.getAttachment(id);
    if (localResult is! SuccessState<AttachmentResponseModel?>) {
      return FailureState(message: (localResult as FailureState).message);
    }
    final attachment = localResult.data;
    if (attachment == null) {
      return const SuccessState(data: true);
    }

    final isUploaded = attachment.uploadStatus == UploadStatus.uploaded;

    return RepositoryHandler.fetchWithFallback<bool>(
      isInternetConnected: _internet.isConnected,
      remoteCallback: () => isUploaded
          ? _remoteDataSource.deleteAttachment(id)
          : Future.value(const SuccessState(data: true)),
      onRemoteSuccess: (_) => _localDataSource.deleteAttachment(id),
      localCallback: () => _localDataSource.deleteAttachment(id),
    );
  }

  // ──────────────────────────────────────────
  // Pick and prepare
  // ──────────────────────────────────────────

  @override
  FutureList<AttachmentEntity> pickAndPrepareAttachment({
    required AttachmentSource source,
    required String workOrderId,
    required String companyId,
    required String uploadedById,
  }) async {
    try {
      final pickedPaths = await _pickPaths(source);
      if (pickedPaths == null || pickedPaths.isEmpty) {
        return const SuccessState(data: []);
      }

      final entities = <AttachmentEntity>[];

      for (final originalPath in pickedPaths) {
        final prepareResult = await _prepareFile(
          originalPath: originalPath,
          workOrderId: workOrderId,
          companyId: companyId,
          uploadedById: uploadedById,
        );

        if (prepareResult is! SuccessState<AttachmentEntity>) {
          return FailureState(message: (prepareResult as FailureState).message);
        }

        var entity = prepareResult.data!;

        if (_internet.isConnected) {
          final uploadResult = await uploadPendingAttachment(entity);
          if (uploadResult is SuccessState<bool>) {
            entity = entity.copyWith(uploadStatus: UploadStatus.uploaded);
          }
        }

        entities.add(entity);
      }

      return SuccessState(data: entities);
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  // ──────────────────────────────────────────
  // Upload pending
  // ──────────────────────────────────────────

  @override
  FutureBool uploadPendingAttachment(AttachmentEntity attachment) async {
    try {
      final localPath = attachment.localPath;
      if (localPath == null || !File(localPath).existsSync()) {
        return FailureState(message: 'Arquivo local não encontrado'.hardcoded);
      }

      final ext = p.extension(localPath).toLowerCase().replaceFirst('.', '');
      final mimeType = _fileService.getMimeType(localPath);
      final objectKey = StorageClient.buildObjectKey(
        companyId: attachment.companyId,
        workOrderId: attachment.workOrderId,
        uuid: attachment.id,
        extension: ext,
      );

      // 1. Request a presigned PUT URL from the Edge Function.
      final presignedResult = await _remoteDataSource.getPresignedUploadUrl(
        objectKey,
      );
      if (presignedResult is! SuccessState<PresignedUrlResponse>) {
        return FailureState(message: (presignedResult as FailureState).message);
      }
      final presigned = presignedResult.data!;

      // 2. Upload file bytes directly to Cloudflare R2.
      final uploadResult = await _storageClient.uploadFile(
        presignedUrl: presigned.uploadUrl,
        filePath: localPath,
        mimeType: mimeType,
      );
      if (uploadResult is! SuccessState<String>) {
        return FailureState(message: (uploadResult as FailureState).message);
      }
      final remoteUrl = uploadResult.data!;

      // Update the entity with the remoteUrl and uploaded status first.
      final updated = attachment.copyWith(
        remoteUrl: remoteUrl,
        uploadStatus: UploadStatus.uploaded,
      );

      // 3. Confirm the upload — saves the entire record on Supabase.
      final confirmResult = await _remoteDataSource.confirmUpload(
        AttachmentResponseModel.fromEntity(updated),
      );
      if (confirmResult is! SuccessState<bool>) {
        return FailureState(message: (confirmResult as FailureState).message);
      }

      // 4. Update the local record with the final remoteUrl and uploaded status.
      return _localDataSource.saveAttachment(
        AttachmentResponseModel.fromEntity(updated),
      );
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  // ──────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────

  Future<List<String>?> _pickPaths(AttachmentSource source) => switch (source) {
    AttachmentSource.cameraPhoto => _fileService.takePhoto().then(
      (path) => path != null ? [path] : null,
    ),
    AttachmentSource.cameraVideo => _fileService.recordVideo().then(
      (path) => path != null ? [path] : null,
    ),
    AttachmentSource.gallery => _fileService.pickMediaFromGallery(),
    AttachmentSource.document => _fileService.pickDocuments(),
  };

  Future<DataState<AttachmentEntity>> _prepareFile({
    required String originalPath,
    required String workOrderId,
    required String companyId,
    required String uploadedById,
  }) async {
    final ext = p.extension(originalPath).toLowerCase().replaceFirst('.', '');
    final fileType = FileType.fromExtension(ext);
    final originalSize = await _fileService.getFileSizeBytes(originalPath);

    final validation = AttachmentFileValidator.validate(ext, originalSize);
    if (validation is AttachmentInvalidType) {
      return FailureState(message: 'Tipo de arquivo não suportado: .$ext');
    }
    if (validation is AttachmentInvalidSize) {
      final maxMb = (validation.maxBytes / (1024 * 1024)).round();
      return FailureState(
        message: 'Arquivo muito grande. O tamanho máximo é $maxMb MB.',
      );
    }

    final entityId = _id();

    final DataState<String> sandboxResult;
    final bool isCompressed;

    switch (fileType) {
      case FileType.image:
        sandboxResult = await _fileService.compressAndSaveImage(originalPath);
        isCompressed = true;
      case FileType.video:
        sandboxResult = await _fileService.compressAndSaveVideo(originalPath);
        isCompressed = true;
      default:
        sandboxResult = await _fileService.copyFileToSandbox(
          originalPath,
          '$entityId.$ext',
        );
        isCompressed = false;
    }

    if (sandboxResult is! SuccessState<String>) {
      return FailureState(message: (sandboxResult as FailureState).message);
    }

    final localPath = sandboxResult.data!;
    final finalSize = await _fileService.getFileSizeBytes(localPath);

    final entity = AttachmentEntity(
      id: entityId,
      workOrderId: workOrderId,
      companyId: companyId,
      uploadedById: uploadedById,
      fileName: p.basename(localPath),
      fileType: fileType,
      localPath: localPath,
      fileSizeBytes: finalSize,
      isCompressed: isCompressed,
      uploadStatus: UploadStatus.pending,
      createdAt: DateTime.now(),
    );

    final saveResult = await _localDataSource.saveAttachment(
      AttachmentResponseModel.fromEntity(entity),
    );
    if (saveResult is FailureState<bool>) {
      return FailureState(message: saveResult.message);
    }

    return SuccessState(data: entity);
  }

  String _id() => const Uuid().v4();
}
