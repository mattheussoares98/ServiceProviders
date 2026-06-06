import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.workOrderId,
    required this.companyId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.completedAt,
    this.completedById,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String workOrderId;
  final String companyId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completedById;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        workOrderId,
        companyId,
        title,
        description,
        isCompleted,
        completedAt,
        completedById,
        sortOrder,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
