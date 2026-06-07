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
  }) {
    return ChecklistTemplateEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  ChecklistTemplateEntity annulDescription() => ChecklistTemplateEntity(
        id: id,
        companyId: companyId,
        name: name,
        description: null,
        categoryId: categoryId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  ChecklistTemplateEntity annulCategoryId() => ChecklistTemplateEntity(
        id: id,
        companyId: companyId,
        name: name,
        description: description,
        categoryId: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  ChecklistTemplateEntity annulDeletedAt() => ChecklistTemplateEntity(
        id: id,
        companyId: companyId,
        name: name,
        description: description,
        categoryId: categoryId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );
}
