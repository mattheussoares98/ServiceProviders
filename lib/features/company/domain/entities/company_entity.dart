import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/plan_type.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';

class CompanyEntity extends Equatable {
  const CompanyEntity({
    required this.id,
    required this.name,
    this.document,
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
  final String? document;
  final String? logoUrl;
  final bool isActive;
  final PlanType planType;
  final WorkType workType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get requiresCustomer => workType.requiresCustomer;
  bool get requiresLocation => workType.requiresLocation;
  bool get supportsOwnLocations => workType.supportsOwnLocations;
  bool get supportsCustomers => workType.supportsCustomers;
  bool get canHireServiceProviders => workType.canHireServiceProviders;
  bool get isInternalOnly => workType.isInternalOnly;
  bool get isServiceProviderOnly => workType.isServiceProviderOnly;
  bool get isHybrid => workType.isHybrid;
  bool canUpgradeTo(WorkType target) => workType.canUpgradeTo(target);

  @override
  List<Object?> get props => [
    id,
    name,
    document,
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
    String? document,
    String? logoUrl,
    bool? isActive,
    PlanType? planType,
    WorkType? workType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulDeletedAt,
    bool? annulDocument,
    bool? annulLogoUrl,
  }) {
    return CompanyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      document: annulDocument == true ? null : (document ?? this.document),
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
