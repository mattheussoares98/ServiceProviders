import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/file_type.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'attachments_state.dart';

@injectable
class AttachmentsCubit extends BaseCubit<AttachmentsState> {
  AttachmentsCubit({
    required AttachmentsCubitUseCases useCases,
    @factoryParam required String workOrderId,
  }) : _useCases = useCases,
       _workOrderId = workOrderId,
       super(const AttachmentsState.empty()) {
    refreshAttachments();
    _initRealtime();
  }

  final AttachmentsCubitUseCases _useCases;
  final String _workOrderId;
  StreamSubscription<RealtimeEvent<AttachmentEntity>>? _realtimeSubscription;

  void _initRealtime() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _useCases
        .watchAttachmentsRealtime(workOrderId: _workOrderId)
        .listen(_handleRealtimeEvent);
  }

  void _handleRealtimeEvent(RealtimeEvent<AttachmentEntity> event) {
    if (isClosed) return;
    refreshAttachments();
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    return super.close();
  }

  Future<void> refreshAttachments() async {
    emit(state.copyWith(status: DataStatus.loading));
    final result = await _useCases.getAttachments(_workOrderId);
    if (isClosed) return;

    if (result is SuccessState<List<AttachmentEntity>>) {
      final list = result.data ?? [];
      emit(
        state.copyWith(
          status: DataStatus.loaded,
          attachments: list,
          annulErrorMessage: true,
        ),
      );

      await _loadVideoThumbnails(list);

      // Auto-upload pending attachments on refresh/load
      for (final attachment in list.where(
        (e) => e.uploadStatus == UploadStatus.pending,
      )) {
        unawaited(_uploadAttachment(attachment));
      }
    } else {
      emit(
        state.copyWith(
          status: DataStatus.loadingError,
          errorMessage: result.message,
        ),
      );
    }
  }

  Future<void> retryUpload(AttachmentEntity attachment) async {
    final updatedList = state.attachments.map((item) {
      if (item.id == attachment.id) {
        return item.copyWith(uploadStatus: UploadStatus.pending);
      }
      return item;
    }).toList();
    emit(state.copyWith(attachments: updatedList));

    await _uploadAttachment(attachment);
  }

  /// [workOrderCompanyId] is the tenant that owns the work order. It must come
  /// from the work order itself, not from the session: in provider mode the
  /// session company is the provider's own employer (or empty for a
  /// provider-only user), never the contracting company being attached to.
  Future<void> pickAttachment(
    AttachmentSource source, {
    String? workOrderCompanyId,
    bool autoUpload = false,
  }) async {
    // Prune the sandbox before picking new files to prevent storage overflow
    await _useCases.pruneSandbox();

    final user = _useCases.getSessionUser();
    final companyId = workOrderCompanyId?.isNotEmpty == true
        ? workOrderCompanyId!
        : _useCases.getActiveCompanyId();
    final result = await _useCases.pickAttachment(
      PickAttachmentParams(
        source: source,
        workOrderId: _workOrderId,
        companyId: companyId,
        userId: user.id,
        onFilesPicked: (count) {
          emit(state.copyWith(processingCount: count));
        },
      ),
    );
    if (isClosed) return;

    emit(state.copyWith(processingCount: 0));

    if (result is SuccessState<List<AttachmentEntity>>) {
      final pickedList = result.data ?? [];
      if (pickedList.isEmpty) return;

      final newAttachments = <AttachmentEntity>[];

      for (final newFile in pickedList) {
        final isDuplicate = state.attachments.any((existing) {
          if (existing.originalPath != null &&
              newFile.originalPath != null &&
              existing.originalPath == newFile.originalPath) {
            return true;
          }
          return existing.fileName == newFile.fileName &&
              existing.fileSizeBytes == newFile.fileSizeBytes;
        });

        if (isDuplicate) {
          unawaited(_useCases.deleteAttachment(newFile.id));
        } else {
          newAttachments.add(newFile);
        }
      }

      if (newAttachments.isEmpty) return;

      final updatedList = List<AttachmentEntity>.from(state.attachments)
        ..addAll(newAttachments);
      emit(state.copyWith(attachments: updatedList));
      await _loadVideoThumbnails(newAttachments);

      if (autoUpload) {
        for (final attachment in newAttachments) {
          unawaited(_uploadAttachment(attachment));
        }
      }
    } else {
      showDataStateToast(
        result,
        message: 'Falha ao selecionar arquivo'.hardcoded,
      );
    }
  }

  Future<bool> uploadPending() async {
    final pending = state.attachments
        .where(
          (e) =>
              e.uploadStatus == UploadStatus.pending ||
              e.uploadStatus == UploadStatus.failed,
        )
        .toList();
    if (pending.isEmpty) return true;

    final results = await Future.wait([
      for (final attachment in pending) _uploadAttachment(attachment),
    ]);

    return !results.contains(false);
  }

  Future<bool> _uploadAttachment(AttachmentEntity attachment) async {
    final uploadingSet = Set<String>.from(state.uploadingIds)
      ..add(attachment.id);
    emit(state.copyWith(uploadingIds: uploadingSet));

    final result = await _useCases.uploadAttachment(attachment);
    if (isClosed) return false;

    final doneSet = Set<String>.from(state.uploadingIds)..remove(attachment.id);

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(uploadingIds: doneSet));
      await refreshAttachments();
      return true;
    } else {
      final updatedList = state.attachments.map((item) {
        if (item.id == attachment.id) {
          return item.copyWith(uploadStatus: UploadStatus.failed);
        }
        return item;
      }).toList();

      emit(state.copyWith(attachments: updatedList, uploadingIds: doneSet));
      showDataStateToast(result, message: 'Falha ao enviar anexo'.hardcoded);
      return false;
    }
  }

  Future<bool> deleteAttachment(String id, {bool autoDelete = false}) async {
    if (autoDelete) {
      final result = await _useCases.deleteAttachment(id);
      if (result is SuccessState<bool> && result.data == true) {
        final updatedList = state.attachments
            .where((item) => item.id != id)
            .toList();
        emit(state.copyWith(attachments: updatedList));
        return true;
      } else {
        showDataStateToast(result, message: 'Falha ao remover anexo'.hardcoded);
        return false;
      }
    }

    final pending = Set<String>.from(state.pendingDeletions)..add(id);
    final updatedList = state.attachments
        .where((item) => item.id != id)
        .toList();
    emit(state.copyWith(attachments: updatedList, pendingDeletions: pending));
    return true;
  }

  Future<void> openAttachment(AttachmentEntity attachment) async {
    // Touch lastAccessedAt when opening an attachment
    unawaited(_useCases.touchLastAccessed(attachment.id));
    final result = await _useCases.openAttachment(attachment);
    if (isClosed) return;

    if (result is! SuccessState<void>) {
      showDataStateToast(result);
    }
  }

  Future<void> _loadVideoThumbnails(List<AttachmentEntity> list) async {
    final videos = list.where((e) => e.fileType == FileType.video).toList();
    if (videos.isEmpty) return;

    final updatedThumbnails = Map<String, String>.from(state.videoThumbnails);
    var changed = false;

    await Future.wait(
      videos.map((video) async {
        final path = video.localPath ?? video.remoteUrl;
        if (path == null || path.isEmpty) return;

        if (updatedThumbnails.containsKey(video.id)) return;

        final res = await _useCases.getVideoThumbnail(path);
        if (res is SuccessState<String> && res.data != null) {
          updatedThumbnails[video.id] = res.data!;
          changed = true;
        }
      }),
    );

    if (changed && !isClosed) {
      emit(state.copyWith(videoThumbnails: updatedThumbnails));
    }
  }
}
