import 'package:equatable/equatable.dart';

class WorkOrderHistoryEntity extends Equatable {
  const WorkOrderHistoryEntity({
    required this.id,
    required this.workOrderId,
    required this.companyId,
    required this.userId,
    required this.action,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  final String id;
  final String workOrderId;
  final String companyId;
  final String userId;
  final String action;
  final String? oldValue;
  final String? newValue;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        workOrderId,
        companyId,
        userId,
        action,
        oldValue,
        newValue,
        createdAt,
      ];
}
