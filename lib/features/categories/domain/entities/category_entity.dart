import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    this.color,
    required this.createdAt,
    this.deletedAt,
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
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  CategoryEntity annulDescription() => CategoryEntity(
        id: id,
        companyId: companyId,
        name: name,
        description: null,
        color: color,
        createdAt: createdAt,
        deletedAt: deletedAt,
      );

  CategoryEntity annulColor() => CategoryEntity(
        id: id,
        companyId: companyId,
        name: name,
        description: description,
        color: null,
        createdAt: createdAt,
        deletedAt: deletedAt,
      );

  CategoryEntity annulDeletedAt() => CategoryEntity(
        id: id,
        companyId: companyId,
        name: name,
        description: description,
        color: color,
        createdAt: createdAt,
        deletedAt: null,
      );
}
