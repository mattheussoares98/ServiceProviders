part of 'attachments_cubit.dart';

class AttachmentsState extends BaseState {
  const AttachmentsState({
    required super.status,
    this.attachments = const [],
    this.uploadingIds = const {},
    super.errorMessage,
  });

  const AttachmentsState.empty() : this(status: StateStatus.initial);

  final List<AttachmentEntity> attachments;
  final Set<String> uploadingIds; // tracks which items show a progress indicator

  @override
  List<Object?> get props => [status, attachments, uploadingIds, errorMessage];

  AttachmentsState copyWith({
    StateStatus? status,
    List<AttachmentEntity>? attachments,
    Set<String>? uploadingIds,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return AttachmentsState(
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      uploadingIds: uploadingIds ?? this.uploadingIds,
      errorMessage: annulErrorMessage == true ? null : errorMessage ?? this.errorMessage,
    );
  }
}