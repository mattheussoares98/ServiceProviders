import 'package:equatable/equatable.dart';

class SectorEntity extends Equatable {
  const SectorEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SectorEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulDeletedAt,
  }) {
    return SectorEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : (deletedAt ?? this.deletedAt),
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
