import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_read_scope.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_update_scope.dart';

class UserWorkOrdersPermissionOverrideEntity extends Equatable {
  const UserWorkOrdersPermissionOverrideEntity({
    required this.readScope,
    required this.create,
    required this.updateScope,
    required this.delete,
    required this.changeStatus,
    required this.reassign,
    required this.managePendingRequests,
    required this.deleteObservation,
  });

  const UserWorkOrdersPermissionOverrideEntity.empty()
    : readScope = null,
      create = null,
      updateScope = null,
      delete = null,
      changeStatus = null,
      reassign = null,
      managePendingRequests = null,
      deleteObservation = null;

  final WorkOrderReadScope? readScope;
  final bool? create;
  final WorkOrderUpdateScope? updateScope;
  final bool? delete;
  final bool? changeStatus;
  final bool? reassign;
  final bool? managePendingRequests;
  final bool? deleteObservation;

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

  UserWorkOrdersPermissionOverrideEntity copyWith({
    WorkOrderReadScope? readScope,
    bool? create,
    WorkOrderUpdateScope? updateScope,
    bool? delete,
    bool? changeStatus,
    bool? reassign,
    bool? managePendingRequests,
    bool? deleteObservation,
    bool? annulReadScope,
    bool? annulCreate,
    bool? annulUpdateScope,
    bool? annulDelete,
    bool? annulChangeStatus,
    bool? annulReassign,
    bool? annulManagePendingRequests,
    bool? annulDeleteObservation,
  }) {
    return UserWorkOrdersPermissionOverrideEntity(
      readScope: annulReadScope == true ? null : readScope ?? this.readScope,
      create: annulCreate == true ? null : create ?? this.create,
      updateScope: annulUpdateScope == true
          ? null
          : updateScope ?? this.updateScope,
      delete: annulDelete == true ? null : delete ?? this.delete,
      changeStatus: annulChangeStatus == true
          ? null
          : changeStatus ?? this.changeStatus,
      reassign: annulReassign == true ? null : reassign ?? this.reassign,
      managePendingRequests: annulManagePendingRequests == true
          ? null
          : managePendingRequests ?? this.managePendingRequests,
      deleteObservation: annulDeleteObservation == true
          ? null
          : deleteObservation ?? this.deleteObservation,
    );
  }
}
