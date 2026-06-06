import 'package:equatable/equatable.dart';

final class CompanyEntity extends Equatable {
  const CompanyEntity({
    required this.id,
    required this.name,
    this.cnpj,
    this.logoUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? cnpj;
  final String? logoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        cnpj,
        logoUrl,
        isActive,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
