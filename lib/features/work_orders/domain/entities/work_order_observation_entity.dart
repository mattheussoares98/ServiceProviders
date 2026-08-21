import 'package:equatable/equatable.dart';

class WorkOrderObservationEntity extends Equatable {
  const WorkOrderObservationEntity({
    required this.id,
    required this.companyId,
    required this.workOrderId,
    required this.authorId,
    required this.authorProviderProfileId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String workOrderId;
  /// Set when an internal employee wrote the observation. Mutually exclusive
  /// with [authorProviderProfileId].
  final String? authorId;

  /// Set when the observation came from provider mode.
  final String? authorProviderProfileId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    workOrderId,
    authorId,
    authorProviderProfileId,
    authorName,
    content,
    createdAt,
    updatedAt,
  ];

  WorkOrderObservationEntity copyWith({
    String? id,
    String? companyId,
    String? workOrderId,
    String? authorId,
    String? authorProviderProfileId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkOrderObservationEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      workOrderId: workOrderId ?? this.workOrderId,
      authorId: authorId ?? this.authorId,
      authorProviderProfileId:
          authorProviderProfileId ?? this.authorProviderProfileId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
