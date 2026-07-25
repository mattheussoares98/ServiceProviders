import 'package:equatable/equatable.dart';

class WorkOrderObservationEntity extends Equatable {
  const WorkOrderObservationEntity({
    required this.id,
    required this.companyId,
    required this.workOrderId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String companyId;
  final String workOrderId;
  final String authorId;
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
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
