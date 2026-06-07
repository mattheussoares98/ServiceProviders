import 'package:clean_architecture/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:equatable/equatable.dart';

class ChecklistItemEntity extends Equatable {
  const ChecklistItemEntity({
    required this.id,
    required this.templateId,
    required this.companyId,
    required this.label,
    required this.type,
    required this.isRequired,
    this.options,
    required this.sortOrder,
    required this.createdAt,
    this.deletedAt,
  });

  final String id;
  final String templateId;
  final String companyId;
  final String label;
  final ChecklistItemType type;
  final bool isRequired;
  final List<String>? options;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        templateId,
        companyId,
        label,
        type,
        isRequired,
        options,
        sortOrder,
        createdAt,
        deletedAt,
      ];

  ChecklistItemEntity copyWith({
    String? id,
    String? templateId,
    String? companyId,
    String? label,
    ChecklistItemType? type,
    bool? isRequired,
    List<String>? options,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return ChecklistItemEntity(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      companyId: companyId ?? this.companyId,
      label: label ?? this.label,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  ChecklistItemEntity annulOptions() => ChecklistItemEntity(
        id: id,
        templateId: templateId,
        companyId: companyId,
        label: label,
        type: type,
        isRequired: isRequired,
        options: null,
        sortOrder: sortOrder,
        createdAt: createdAt,
        deletedAt: deletedAt,
      );

  ChecklistItemEntity annulDeletedAt() => ChecklistItemEntity(
        id: id,
        templateId: templateId,
        companyId: companyId,
        label: label,
        type: type,
        isRequired: isRequired,
        options: options,
        sortOrder: sortOrder,
        createdAt: createdAt,
        deletedAt: null,
      );
}
