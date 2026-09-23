import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/plan_type.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';

class CompanyEntity extends Equatable {
  const CompanyEntity({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.logoUrl,
    required this.isActive,
    this.planType = PlanType.free,
    this.workType = WorkType.internalOnly,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String name;
  final String? cnpj;
  final String? logoUrl;
  final bool isActive;
  final PlanType planType;
  final WorkType workType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    id,
    name,
    cnpj,
    logoUrl,
    isActive,
    planType,
    workType,
    createdAt,
    updatedAt,
    deletedAt,
  ];

  CompanyEntity copyWith({
    String? id,
    String? name,
    String? cnpj,
    String? logoUrl,
    bool? isActive,
    PlanType? planType,
    WorkType? workType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulDeletedAt,
    bool? annulCnpj,
    bool? annulLogoUrl,
  }) {
    return CompanyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      cnpj: annulCnpj == true ? null : (cnpj ?? this.cnpj),
      logoUrl: annulLogoUrl == true ? null : (logoUrl ?? this.logoUrl),
      isActive: isActive ?? this.isActive,
      planType: planType ?? this.planType,
      workType: workType ?? this.workType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
