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

  PauseReasonEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulDeletedAt,
  }) {
    return PauseReasonEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
