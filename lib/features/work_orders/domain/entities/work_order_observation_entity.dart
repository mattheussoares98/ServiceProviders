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
}
