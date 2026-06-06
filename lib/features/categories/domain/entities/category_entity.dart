import 'package:equatable/equatable.dart';

final class CategoryEntity extends Equatable {
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
}
