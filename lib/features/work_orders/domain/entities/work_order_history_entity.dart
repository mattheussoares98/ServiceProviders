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
  }) {
    return WorkOrderHistoryEntity(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  WorkOrderHistoryEntity annulOldValue() => WorkOrderHistoryEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        userId: userId,
        action: action,
        oldValue: null,
        newValue: newValue,
        createdAt: createdAt,
      );

  WorkOrderHistoryEntity annulNewValue() => WorkOrderHistoryEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        userId: userId,
        action: action,
        oldValue: oldValue,
        newValue: null,
        createdAt: createdAt,
      );
}
