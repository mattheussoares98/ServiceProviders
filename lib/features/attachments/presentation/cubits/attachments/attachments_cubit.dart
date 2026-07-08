import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/upload_status.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/repositories/attachments_repository.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/presentation/cubits/attachments/attachments_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'attachments_state.dart';

@injectable
class AttachmentsCubit extends BaseCubit<AttachmentsState> {
  AttachmentsCubit({required AttachmentsCubitUseCases useCases})
    : _useCases = useCases,
      super(const AttachmentsState.empty());

  final AttachmentsCubitUseCases _useCases;
  late String _workOrderId;

  Future<void> init(String workOrderId) async {
    _workOrderId = workOrderId;
    await _refreshAttachments();
  }

  Future<void> _refreshAttachments() async {
    emit(state.copyWith(status: StateStatus.loading));
    final result = await _useCases.getAttachments(_workOrderId);
    if (isClosed) return;

    if (result is SuccessState<List<AttachmentEntity>>) {
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          attachments: result.data ?? [],
          annulErrorMessage: true,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: StateStatus.loadingError,
          errorMessage: result.message,
        ),
      );
    }
  }

  Future<void> pickAttachment(AttachmentSource source) async {
    final user = _useCases.getSessionUser();
    final result = await _useCases.pickAttachment(
      PickAttachmentParams(
        source: source,
        workOrderId: _workOrderId,
        companyId: user.companyId,
        userId: user.id,
      ),
    );
    if (isClosed) return;

    if (result is SuccessState<List<AttachmentEntity>>) {
      final pickedList = result.data ?? [];
      if (pickedList.isEmpty) return;

      final newAttachments = <AttachmentEntity>[];

      for (final newFile in pickedList) {
        final isDuplicate = state.attachments.any(
          (existing) =>
              existing.fileName == newFile.fileName &&
              existing.fileSizeBytes == newFile.fileSizeBytes,
        );

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

      // Start upload for each pending attachment (fire-and-forget)
      for (final attachment in newAttachments.where(
        (e) => e.uploadStatus == UploadStatus.pending,
      )) {
        unawaited(_uploadAttachment(attachment));
      }
    } else {
      showDataStateToast(
        result,
        message: 'Falha ao selecionar arquivo'.hardcoded,
      );
    }
  }

  Future<void> _uploadAttachment(AttachmentEntity attachment) async {
    final uploadingSet = Set<String>.from(state.uploadingIds)
      ..add(attachment.id);
    emit(state.copyWith(uploadingIds: uploadingSet));

    final result = await _useCases.uploadAttachment(attachment);
    if (isClosed) return;

    final doneSet = Set<String>.from(state.uploadingIds)..remove(attachment.id);

    if (result is SuccessState<bool> && result.data == true) {
      emit(state.copyWith(uploadingIds: doneSet));
      await _refreshAttachments();
    } else {
      final updatedList = state.attachments.map((item) {
        if (item.id == attachment.id) {
          return item.copyWith(uploadStatus: UploadStatus.failed);
        }
        return item;
      }).toList();

      emit(state.copyWith(attachments: updatedList, uploadingIds: doneSet));
      showDataStateToast(result, message: 'Falha ao enviar anexo'.hardcoded);
    }
  }

  Future<bool> deleteAttachment(String id) async {
    emit(state.copyWith(status: StateStatus.deleting));
    final result = await _useCases.deleteAttachment(id);
    if (isClosed) return false;

    if (result is SuccessState<bool> && result.data == true) {
      final updatedList = state.attachments
          .where((item) => item.id != id)
          .toList();
      emit(
        state.copyWith(
          status: StateStatus.loaded,
          attachments: updatedList,
          annulErrorMessage: true,
        ),
      );
      return true;
    } else {
      emit(
        state.copyWith(
          status: StateStatus.deletingError,
          errorMessage: state.errorMessage,
        ),
      );
      showDataStateToast(result);
      return false;
    }
  }

  Future<void> openAttachment(AttachmentEntity attachment) async {
    final result = await _useCases.openAttachment(attachment);
    if (isClosed) return;

    if (result is! SuccessState<void>) {
      showDataStateToast(result);
    }
  }
}
