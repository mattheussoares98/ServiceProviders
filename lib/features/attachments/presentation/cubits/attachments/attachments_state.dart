part of 'attachments_cubit.dart';

class AttachmentsState extends BaseState {
  const AttachmentsState({
    this.attachments = const [],
    this.uploadingIds = const {},
    this.pendingDeletions = const {},
    this.videoThumbnails = const {},
    this.processingCount = 0,
    super.sections,
  });

  const AttachmentsState.empty() : this();

  final List<AttachmentEntity> attachments;
  final Set<String>
  uploadingIds; // tracks which items show a progress indicator
  final Set<String>
  pendingDeletions; // tracks which items are marked for deletion in the UI
  final Map<String, String>
  videoThumbnails; // maps attachment ID to local thumbnail path
  final int processingCount;

  @override
  List<Object?> get props => [
    attachments,
    uploadingIds,
    pendingDeletions,
    videoThumbnails,
    processingCount,
    sections,
  ];

  AttachmentsState copyWith({
    List<AttachmentEntity>? attachments,
    Set<String>? uploadingIds,
    Set<String>? pendingDeletions,
    Map<String, String>? videoThumbnails,
    int? processingCount,
    Map<SectionKey, SectionState>? sections,
  }) {
    return AttachmentsState(
      attachments: attachments ?? this.attachments,
      uploadingIds: uploadingIds ?? this.uploadingIds,
      pendingDeletions: pendingDeletions ?? this.pendingDeletions,
      videoThumbnails: videoThumbnails ?? this.videoThumbnails,
      processingCount: processingCount ?? this.processingCount,
      sections: sections ?? this.sections,
    );
  }
}
