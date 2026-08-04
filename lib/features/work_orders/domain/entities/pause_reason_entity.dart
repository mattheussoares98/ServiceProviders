import 'package:equatable/equatable.dart';

class PauseReasonEntity extends Equatable {
  const PauseReasonEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
