import 'package:equatable/equatable.dart';

class CompanyParameterEntity extends Equatable {
  const CompanyParameterEntity({
    required this.id,
    required this.companyId,
    required this.maxOfflineDurationHours,
    required this.maxOfflinePendingRequests,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String companyId;
  final int maxOfflineDurationHours;
  final int maxOfflinePendingRequests;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    maxOfflineDurationHours,
    maxOfflinePendingRequests,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
