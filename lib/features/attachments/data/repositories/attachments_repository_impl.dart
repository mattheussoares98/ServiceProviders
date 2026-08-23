import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/constants/local_storage_limits.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_local_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_model.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/value_objects/attachment_file_validator.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
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
    required SessionRepository sessionRepository,
  }) : _internet = internet,
       _fileService = fileService,
       _storageClient = storageClient,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _sessionRepository = sessionRepository;

  final InternetClient _internet;
  final FileService _fileService;
  final StorageClient _storageClient;
  final AttachmentsRemoteDataSource _remoteDataSource;
  final AttachmentsLocalDataSource _localDataSource;
  final SessionRepository _sessionRepository;

  bool get _isProviderMode =>
      AppMode.fromName(_sessionRepository.getSelectedMode()) ==
      AppMode.provider;

  // ──────────────────────────────────────────
  // Standard CRUD
  // ──────────────────────────────────────────

  @override
  FutureList<AttachmentEntity> getAttachmentsByWorkOrder(
    String workOrderId,
  ) async {
    if (_isProviderMode && !_internet.isConnected) {
      return FailureState.noInternet();
    }

    List<AttachmentModel> models = [];

    if (_internet.isConnected) {
      final remoteResult = await _remoteDataSource.getAttachmentsByWorkOrder(
        workOrderId,
      );
      if (remoteResult is! SuccessState<List<AttachmentModel>>) {
        if (_isProviderMode) {
          return FailureState(
            message: (remoteResult as FailureState).message,
            error: remoteResult.error,
            statusCode: remoteResult.statusCode,
            response: remoteResult.response,
          );
        }
      } else {
        final remoteModels = remoteResult.data ?? <AttachmentModel>[];
        if (_isProviderMode) {
          models = remoteModels;
        } else {
          final remoteIds = remoteModels.map((m) => m.id).toSet();
          await Future.wait([
            for (final model in remoteModels)
              _saveRemoteModelPreservingLocalPath(model),
          ]);

          final localResult = await _localDataSource.getAttachmentsByWorkOrder(
            workOrderId,
          );
          if (localResult is SuccessState<List<AttachmentModel>>) {
            final localModels = localResult.data ?? <AttachmentModel>[];
            await Future.wait([
              for (final localModel in localModels)
                if (localModel.uploadStatus == UploadStatus.uploaded &&
                    !remoteIds.contains(localModel.id))
                  _localDataSource.deleteAttachment(localModel.id),
            ]);
          }
        }
      }
    }

    if (!_isProviderMode) {
      final localResult = await _localDataSource.getAttachmentsByWorkOrder(
        workOrderId,
      );
      if (localResult is! SuccessState<List<AttachmentModel>>) {
        return FailureState(
          message: (localResult as FailureState).message,
          error: localResult.error,
          statusCode: localResult.statusCode,
          response: localResult.response,
        );
      }
      models = localResult.data ?? <AttachmentModel>[];
    }

    final entities = await Future.wait(models.map(_toEntityWithResolvedPath));
    return SuccessState(data: entities);
  }

  Future<void> _saveRemoteModelPreservingLocalPath(
    AttachmentModel remoteModel,
  ) async {
    final existingResult = await _localDataSource.getAttachment(remoteModel.id);
    await _localDataSource.saveAttachment(
      AttachmentModel.fromEntity(
        remoteModel.copyWith(localPath: existingResult.data?.localPath),
      ),
    );
  }

  Future<AttachmentEntity> _toEntityWithResolvedPath(
    AttachmentModel model,
  ) async {
    final entity = model.toEntity();
    final localPath = entity.localPath;

    // ── Case 1: already cached locally — verify file still exists ──────────
    if (localPath != null && localPath.isNotEmpty) {
      final resolvedPath = await _fileService.resolveSandboxPath(localPath);
      if (resolvedPath != null && await _fileService.fileExists(resolvedPath)) {
        // Touch lastAccessedAt asynchronously
        await _localDataSource.touchLastAccessed(model.id);
        return entity.copyWith(
          localPath: resolvedPath,
          lastAccessedAt: DateTime.now(),
        );
      }
      // File record exists but the physical file is gone — clear the stale path
      // and fall through to re-download if a remoteUrl is available.
      await _localDataSource.saveAttachment(
        AttachmentModel.fromEntity(entity.copyWith(annulLocalPath: true)),
      );
    }

    // ── Case 2: no local file — try to download from Cloudflare ────────────
    final remoteUrl = entity.remoteUrl;
    final isDownloadable =
        entity.uploadStatus == UploadStatus.uploaded &&
        remoteUrl != null &&
        remoteUrl.isNotEmpty &&
        // Videos are excluded: they can be 10-50 MB and are streamed instead.
        entity.fileType != FileType.video;

    if (!isDownloadable) {
      return entity.copyWith(annulLocalPath: true);
    }

    // Derive a stable, unique filename from the attachment ID + remote extension.
    final remoteExt = p.extension(Uri.parse(remoteUrl).path);
    final cacheFileName = '${entity.id}$remoteExt';

    final downloadResult = await _fileService.downloadUrlToSandbox(
      remoteUrl,
      cacheFileName,
    );

    if (downloadResult is! SuccessState<String>) {
      // Download failed (network error, etc.) — UI will fall back to remoteUrl.
      return entity.copyWith(annulLocalPath: true);
    }

    final absolutePath = downloadResult.data!;
    final fileSizeBytes = await _fileService.getFileSizeBytes(absolutePath);

    // Persist the new localPath so subsequent loads are fully offline.
    await _localDataSource.saveAttachment(
      AttachmentModel.fromEntity(
        entity.copyWith(localPath: cacheFileName, fileSizeBytes: fileSizeBytes),
      ),
    );
    await _localDataSource.touchLastAccessed(model.id);

    return entity.copyWith(
      localPath: absolutePath,
      fileSizeBytes: fileSizeBytes,
      lastAccessedAt: DateTime.now(),
    );
  }

  @override
  FutureVoid touchLastAccessed(String id) =>
      _localDataSource.touchLastAccessed(id);

  @override
  FutureData<int> getSandboxSizeBytes() =>
      _localDataSource.getTotalSandboxBytes();

  @override
  FutureVoid pruneSandbox() async {
    try {
      final sizeResult = await getSandboxSizeBytes();
      if (sizeResult is! SuccessState<int>) return SuccessState.nil;

      int currentSize = sizeResult.data ?? 0;
      if (currentSize <= kSandboxQuotaBytes) {
        return SuccessState.nil;
      }

      final listResult = await _localDataSource
          .getUploadedOrderedByLastAccess();
      if (listResult is! SuccessState<List<AttachmentModel>>) {
        return SuccessState.nil;
      }

      final candidates = listResult.data ?? [];
      for (final candidate in candidates) {
        if (currentSize <= kSandboxQuotaBytes) break;

        final localPath = candidate.localPath;
        if (localPath != null && localPath.isNotEmpty) {
          final resolvedPath = await _fileService.resolveSandboxPath(localPath);
          if (resolvedPath != null &&
              await _fileService.fileExists(resolvedPath)) {
            await _fileService.deleteLocalFile(resolvedPath);
          }
        }

        final updated = candidate.copyWith(annulLocalPath: true);
        await _localDataSource.saveAttachment(
          AttachmentModel.fromEntity(updated),
        );

        currentSize -= candidate.fileSizeBytes ?? 0;
      }

      return SuccessState.nil;
    } catch (e) {
      return FailureState(message: e.toString());
    }
  }

  @override
  FutureVoid clearLocalAttachments() async {
    try {
      final listResult = await _localDataSource
          .getUploadedOrderedByLastAccess();
      if (listResult is! SuccessState<List<AttachmentModel>>) {
        return SuccessState.nil;
      }

      final uploaded = listResult.data ?? [];
      for (final attachment in uploaded) {
        final localPath = attachment.localPath;
        if (localPath != null && localPath.isNotEmpty) {
          final resolvedPath = await _fileService.resolveSandboxPath(localPath);
          if (resolvedPath != null &&
              await _fileService.fileExists(resolvedPath)) {
            await _fileService.deleteLocalFile(resolvedPath);
          }
        }

        final updated = attachment.copyWith(annulLocalPath: true);
        await _localDataSource.saveAttachment(
          AttachmentModel.fromEntity(updated),
        );
      }
      return SuccessState.nil;
    } catch (e) {
      return FailureState(message: e.toString());
    }
  }

  @override
  FutureBool createAttachment(AttachmentEntity attachment) => _isProviderMode
      ? Future.value(const SuccessState(data: true))
      : _localDataSource.saveAttachment(
          AttachmentModel.fromEntity(attachment),
        );

  @override
  FutureBool deleteAttachment(String id) async {
    if (_isProviderMode) {
      if (!_internet.isConnected) {
        return FailureState.noInternet();
      }
      return _remoteDataSource.deleteAttachment(id);
    }
    try {
      final localResult = await _localDataSource.getAttachment(id);
      if (localResult is! SuccessState<AttachmentModel?>) {
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
    } catch (e) {
      return FailureState(message: e.toString());
    }
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
    void Function(int count)? onFilesPicked,
    bool multiple = true,
  }) async {
    try {
      final pickedFiles = await _pickFiles(source, multiple: multiple);
      if (pickedFiles == null || pickedFiles.isEmpty) {
        return const SuccessState(data: []);
      }

      onFilesPicked?.call(pickedFiles.length);

      final entities = <AttachmentEntity>[];

      for (final picked in pickedFiles) {
        final prepareResult = await _prepareFile(
          originalPath: picked.path,
          originalName: picked.name,
          workOrderId: workOrderId,
          companyId: companyId,
          uploadedById: uploadedById,
        );

        if (prepareResult is! SuccessState<AttachmentEntity>) {
          return FailureState(message: (prepareResult as FailureState).message);
        }

        entities.add(prepareResult.data!);
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
      if (localPath == null || !await _fileService.fileExists(localPath)) {
        return FailureState(message: 'Arquivo local não encontrado'.hardcoded);
      }

      if (_isProviderMode) {
        if (!_internet.isConnected) {
          return FailureState.noInternet();
        }
        final ext = _getExtension(localPath, attachment.fileName);
        final mimeType = _fileService.getMimeType(localPath);
        final objectKey = StorageClient.buildObjectKey(
          companyId: attachment.companyId,
          workOrderId: attachment.workOrderId,
          uuid: attachment.id,
          extension: ext,
        );

        final presignedResult = await _remoteDataSource.getPresignedUploadUrl(
          objectKey,
        );
        if (presignedResult is! SuccessState<PresignedUrlResponse>) {
          return FailureState(
            message: (presignedResult as FailureState).message,
          );
        }
        final presigned = presignedResult.data!;

        final uploadResult = await _storageClient.uploadFile(
          presignedUrl: presigned.uploadUrl,
          filePath: localPath,
          mimeType: mimeType,
        );
        if (uploadResult is! SuccessState<String>) {
          return FailureState(message: (uploadResult as FailureState).message);
        }
        final remoteUrl = presigned.publicUrl;

        final updated = attachment.copyWith(
          remoteUrl: remoteUrl,
          uploadStatus: UploadStatus.uploaded,
        );

        return _remoteDataSource.confirmUpload(
          AttachmentModel.fromEntity(updated),
        );
      }

      // Check if identical attachment already exists remotely
      if (_internet.isConnected) {
        final hash = attachment.originalPath;
        if (hash != null && hash.isNotEmpty) {
          final existingResult = await _remoteDataSource.getAttachmentByHash(
            workOrderId: attachment.workOrderId,
            hash: hash,
          );
          if (existingResult is SuccessState<AttachmentModel?>) {
            final existing = existingResult.data;
            if (existing != null) {
              if (existing.deletedAt != null) {
                // Restore the remote soft-deleted record
                final restoreResult = await _remoteDataSource.restoreAttachment(
                  id: existing.id,
                  uploadedById: attachment.uploadedById,
                );
                if (restoreResult is SuccessState<bool>) {
                  // Hard delete local pending record
                  await _localDataSource.hardDeleteAttachment(attachment.id);
                  // Save restored record to local DB
                  final restoredModel = AttachmentModel.fromEntity(
                    existing.copyWith(
                      annulDeletedAt: true,
                      uploadedById: attachment.uploadedById,
                      uploadStatus: UploadStatus.uploaded,
                    ),
                  );
                  await _localDataSource.saveAttachment(restoredModel);
                  return const SuccessState(data: true);
                }
              } else {
                // Already exists and is active remotely
                // Hard delete local pending record
                await _localDataSource.hardDeleteAttachment(attachment.id);
                // Save the active record to local DB
                await _localDataSource.saveAttachment(existing);
                return const SuccessState(data: true);
              }
            }
          }
        }
      }

      final ext = _getExtension(localPath, attachment.fileName);
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
      final remoteUrl = presigned.publicUrl;

      // Update the entity with the remoteUrl and uploaded status first.
      final updated = attachment.copyWith(
        remoteUrl: remoteUrl,
        uploadStatus: UploadStatus.uploaded,
      );

      // 3. Confirm the upload — saves the entire record on Supabase.
      final confirmResult = await _remoteDataSource.confirmUpload(
        AttachmentModel.fromEntity(updated),
      );
      if (confirmResult is! SuccessState<bool>) {
        return FailureState(message: (confirmResult as FailureState).message);
      }

      // 4. Update the local record with the final remoteUrl and uploaded status.
      return _localDataSource.saveAttachment(
        AttachmentModel.fromEntity(updated),
      );
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  // ──────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────

  Future<List<PickedFile>?> _pickFiles(
    AttachmentSource source, {
    bool multiple = true,
  }) => switch (source) {
    // Camera picks always produce unique files — name is not meaningful
    // for deduplication, so we reuse path as the name.
    AttachmentSource.cameraPhoto => _fileService.takePhoto().then(
      (path) => path != null ? [(path: path, name: path, bytes: null)] : null,
    ),
    AttachmentSource.cameraVideo => _fileService.recordVideo().then(
      (path) => path != null ? [(path: path, name: path, bytes: null)] : null,
    ),
    AttachmentSource.gallery => _fileService.pickMediaFromGallery(
      multiple: multiple,
    ),
    AttachmentSource.document => _fileService.pickDocuments(),
  };

  Future<DataState<AttachmentEntity>> _prepareFile({
    required String originalPath,
    required String originalName,
    required String workOrderId,
    required String companyId,
    required String uploadedById,
  }) async {
    final ext = _getExtension(originalPath, originalName);
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

    // DJB2 hash of the raw original bytes — the only stable cross-platform
    // deduplication key. Both XFile.path and XFile.name include a UUID that
    // changes on every pick on iOS and Android.
    final rawBytes = await _fileService.readFileAsBytes(originalPath);
    int hash = 5381;
    for (final byte in rawBytes) {
      hash = ((hash << 5) + hash) + byte;
      hash = hash & 0xFFFFFFFF;
    }
    final contentHash = hash.toRadixString(16);

    final entity = AttachmentEntity(
      id: entityId,
      workOrderId: workOrderId,
      companyId: companyId,
      uploadedById: uploadedById,
      fileName: originalName,
      fileType: fileType,
      localPath: localPath,
      remoteUrl: null,
      fileSizeBytes: finalSize,
      isCompressed: isCompressed,
      uploadStatus: UploadStatus.pending,
      createdAt: DateTime.now(),
      deletedAt: null,
      originalPath: contentHash,
      lastAccessedAt: null,
    );

    return SuccessState(data: entity);
  }

  String _getExtension(String path, [String? fallbackName]) {
    var ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    if (ext.isEmpty) {
      try {
        final uri = Uri.tryParse(path);
        if (uri != null && uri.scheme.isNotEmpty) {
          final filename = uri.path.isNotEmpty
              ? uri.pathSegments.last
              : uri.host;
          ext = p.extension(filename).toLowerCase().replaceFirst('.', '');
        }
      } catch (_) {
        // Fallback if parsing fails due to invalid/custom URI schemes
      }
    }
    if (ext.isEmpty && fallbackName != null && fallbackName.isNotEmpty) {
      ext = p.extension(fallbackName).toLowerCase().replaceFirst('.', '');
    }
    return ext;
  }

  String _id() => const Uuid().v4();
}
