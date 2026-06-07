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

  WorkOrderHistoryEntity copyWith({
    String? id,
    String? workOrderId,
    String? companyId,
    String? userId,
    String? action,
    String? oldValue,
    String? newValue,
    DateTime? createdAt,
    bool? annulOldValue,
    bool? annulNewValue,
  }) {
    return WorkOrderHistoryEntity(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      oldValue: annulOldValue == true ? null : oldValue ?? this.oldValue,
      newValue: annulNewValue == true ? null : newValue ?? this.newValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
