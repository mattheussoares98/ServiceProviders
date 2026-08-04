import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.color,
    required this.createdAt,
    required this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final String? description;
  final String? color;
  final DateTime createdAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    description,
    color,
    createdAt,
    deletedAt,
  ];

  CategoryEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool? annulDescription,
    bool? annulColor,
    bool? annulDeletedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: annulDescription == true
          ? null
          : description ?? this.description,
      color: annulColor == true ? null : color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
