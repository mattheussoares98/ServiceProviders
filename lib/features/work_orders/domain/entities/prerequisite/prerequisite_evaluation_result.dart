import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_step.dart';

class PrerequisiteEvaluationResult extends Equatable {
  const PrerequisiteEvaluationResult({required this.steps});

  final List<PrerequisiteStep> steps;

  bool get hasPendingRequiredPrerequisites =>
      steps.any((s) => !s.isOptional && !s.isCompleted);

  bool get allCompleted => steps.every((s) => s.isCompleted);

  PrerequisiteStep? get nextPendingStep =>
      steps.firstWhereOrNull((s) => !s.isCompleted);

  @override
  List<Object?> get props => [steps];
}
