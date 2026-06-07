import 'package:equatable/equatable.dart';

class ChecklistTemplateEntity extends Equatable {
  const ChecklistTemplateEntity({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final String? description;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        companyId,
        name,
        description,
        categoryId,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  ChecklistTemplateEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    String? description,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulDescription,
    bool? annulCategoryId,
    bool? annulDeletedAt,
  }) {
    return ChecklistTemplateEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: annulDescription == true ? null : description ?? this.description,
      categoryId: annulCategoryId == true ? null : categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
