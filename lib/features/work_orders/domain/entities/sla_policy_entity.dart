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

  SlaPolicyEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    int? targetHours,
    SlaAppliesTo? appliesTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? Function()? deletedAt,
  }) {
    return SlaPolicyEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      targetHours: targetHours ?? this.targetHours,
      appliesTo: appliesTo ?? this.appliesTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }

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
