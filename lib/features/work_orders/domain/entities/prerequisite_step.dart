import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';

enum PrerequisiteType {
  location,
  area,
  customer,
  asset,
}

class PrerequisiteStep extends Equatable {
  const PrerequisiteStep({
    required this.type,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.permissionRequired,
    required this.isCompleted,
    this.isOptional = false,
    this.canPerformAction = true,
  });

  final PrerequisiteType type;
  final String title;
  final String description;
  final String actionLabel;
  final ActionPermission? permissionRequired;
  final bool isCompleted;
  final bool isOptional;
  final bool canPerformAction;

  PrerequisiteStep copyWith({
    PrerequisiteType? type,
    String? title,
    String? description,
    String? actionLabel,
    ActionPermission? permissionRequired,
    bool? isCompleted,
    bool? isOptional,
    bool? canPerformAction,
  }) {
    return PrerequisiteStep(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      actionLabel: actionLabel ?? this.actionLabel,
      permissionRequired: permissionRequired ?? this.permissionRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      isOptional: isOptional ?? this.isOptional,
      canPerformAction: canPerformAction ?? this.canPerformAction,
    );
  }

  @override
  List<Object?> get props => [
    type,
    title,
    description,
    actionLabel,
    permissionRequired,
    isCompleted,
    isOptional,
    canPerformAction,
  ];
}

class PrerequisiteEvaluationResult extends Equatable {
  const PrerequisiteEvaluationResult({
    required this.steps,
  });

  final List<PrerequisiteStep> steps;

  bool get hasPendingRequiredPrerequisites =>
      steps.any((s) => !s.isOptional && !s.isCompleted);

  bool get allCompleted => steps.every((s) => s.isCompleted);

  PrerequisiteStep? get nextPendingStep =>
      steps.firstWhereOrNull((s) => !s.isCompleted);

  @override
  List<Object?> get props => [steps];
}
