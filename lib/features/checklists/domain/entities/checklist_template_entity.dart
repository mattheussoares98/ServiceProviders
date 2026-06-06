import 'package:equatable/equatable.dart';

final class ChecklistTemplateEntity extends Equatable {
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
}
