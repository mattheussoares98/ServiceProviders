import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_read_scope.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_update_scope.dart';

class UserWorkOrdersPermissionOverrideEntity extends Equatable {
  const UserWorkOrdersPermissionOverrideEntity({
    this.readScope,
    this.create,
    this.updateScope,
    this.delete,
    this.changeStatus,
    this.reassign,
    this.approvePause,
    this.approveCompletion,
  });

  const UserWorkOrdersPermissionOverrideEntity.empty()
    : readScope = null,
      create = null,
      updateScope = null,
      delete = null,
      changeStatus = null,
      reassign = null,
      approvePause = null,
      approveCompletion = null;

  final WorkOrderReadScope? readScope;
  final bool? create;
  final WorkOrderUpdateScope? updateScope;
  final bool? delete;
  final bool? changeStatus;
  final bool? reassign;
  final bool? approvePause;
  final bool? approveCompletion;

  @override
  List<Object?> get props => [
    readScope,
    create,
    updateScope,
    delete,
    changeStatus,
    reassign,
    approvePause,
    approveCompletion,
  ];

  UserWorkOrdersPermissionOverrideEntity copyWith({
    WorkOrderReadScope? readScope,
    bool? create,
    WorkOrderUpdateScope? updateScope,
    bool? delete,
    bool? changeStatus,
    bool? reassign,
    bool? approvePause,
    bool? approveCompletion,
    bool? annulReadScope,
    bool? annulCreate,
    bool? annulUpdateScope,
    bool? annulDelete,
    bool? annulChangeStatus,
    bool? annulReassign,
    bool? annulApprovePause,
    bool? annulApproveCompletion,
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
      approvePause: annulApprovePause == true
          ? null
          : approvePause ?? this.approvePause,
      approveCompletion: annulApproveCompletion == true
          ? null
          : approveCompletion ?? this.approveCompletion,
    );
  }
}
