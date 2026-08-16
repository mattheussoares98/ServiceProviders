import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_read_scope.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_update_scope.dart';

class WorkOrdersPermissionEntity extends Equatable {
  const WorkOrdersPermissionEntity({
    required this.readScope,
    required this.create,
    required this.updateScope,
    required this.delete,
    required this.changeStatus,
    required this.reassign,
    required this.managePendingRequests,
    required this.deleteObservation,
  });

  const WorkOrdersPermissionEntity.defaultTechnical()
    : readScope = WorkOrderReadScope.assigned,
      create = false,
      updateScope = WorkOrderUpdateScope.assigned,
      delete = false,
      changeStatus = true,
      reassign = false,
      managePendingRequests = false,
      deleteObservation = false;

  const WorkOrdersPermissionEntity.defaultSupervisor()
    : readScope = WorkOrderReadScope.all,
      create = true,
      updateScope = WorkOrderUpdateScope.all,
      delete = true,
      changeStatus = true,
      reassign = true,
      managePendingRequests = true,
      deleteObservation = true;

  const WorkOrdersPermissionEntity.defaultAdmin()
    : readScope = WorkOrderReadScope.all,
      create = true,
      updateScope = WorkOrderUpdateScope.all,
      delete = true,
      changeStatus = true,
      reassign = true,
      managePendingRequests = true,
      deleteObservation = true;

  final WorkOrderReadScope readScope;
  final bool create;
  final WorkOrderUpdateScope updateScope;
  final bool delete;
  final bool changeStatus;
  final bool reassign;
  final bool managePendingRequests;
  final bool deleteObservation;

  @override
  List<Object?> get props => [
    readScope,
    create,
    updateScope,
    delete,
    changeStatus,
    reassign,
    managePendingRequests,
    deleteObservation,
  ];

  WorkOrdersPermissionEntity copyWith({
    WorkOrderReadScope? readScope,
    bool? create,
    WorkOrderUpdateScope? updateScope,
    bool? delete,
    bool? changeStatus,
    bool? reassign,
    bool? managePendingRequests,
    bool? deleteObservation,
  }) {
    return WorkOrdersPermissionEntity(
      readScope: readScope ?? this.readScope,
      create: create ?? this.create,
      updateScope: updateScope ?? this.updateScope,
      delete: delete ?? this.delete,
      changeStatus: changeStatus ?? this.changeStatus,
      reassign: reassign ?? this.reassign,
      managePendingRequests:
          managePendingRequests ?? this.managePendingRequests,
      deleteObservation: deleteObservation ?? this.deleteObservation,
    );
  }
}
