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
}
