import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/sla_applies_to.dart';

class SlaPolicyEntity extends Equatable {
  const SlaPolicyEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.targetHours,
    required this.appliesTo,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final int targetHours;
  final SlaAppliesTo appliesTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    targetHours,
    appliesTo,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
