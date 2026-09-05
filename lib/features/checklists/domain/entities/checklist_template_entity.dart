import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';

class ChecklistTemplateEntity extends Equatable {
  const ChecklistTemplateEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    this.items = const [],
  });

  final String id;
  final String companyId;
  final String name;
  final String? description;
  final String? categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<ChecklistItemEntity> items;

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
    items,
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
    List<ChecklistItemEntity>? items,
    bool? annulDescription,
    bool? annulCategoryId,
    bool? annulDeletedAt,
  }) {
    return ChecklistTemplateEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: annulDescription == true
          ? null
          : description ?? this.description,
      categoryId: annulCategoryId == true
          ? null
          : categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
      items: items ?? this.items,
    );
  }
}
