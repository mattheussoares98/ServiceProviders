part of 'attachments_cubit.dart';

class AttachmentsState extends BaseState {
  const AttachmentsState({
    required super.status,
    this.attachments = const [],
    this.uploadingIds = const {},
    this.pendingDeletions = const {},
    super.errorMessage,
  });

  const AttachmentsState.empty() : this(status: StateStatus.initial);

  final List<AttachmentEntity> attachments;
  final Set<String> uploadingIds; // tracks which items show a progress indicator
  final Set<String> pendingDeletions; // tracks which items are marked for deletion in the UI

  @override
  List<Object?> get props => [status, attachments, uploadingIds, pendingDeletions, errorMessage];

  AttachmentsState copyWith({
    StateStatus? status,
    List<AttachmentEntity>? attachments,
    Set<String>? uploadingIds,
    Set<String>? pendingDeletions,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return AttachmentsState(
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      uploadingIds: uploadingIds ?? this.uploadingIds,
      pendingDeletions: pendingDeletions ?? this.pendingDeletions,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
