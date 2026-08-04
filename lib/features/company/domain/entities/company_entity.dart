import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  const CompanyEntity({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.logoUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
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

  CompanyEntity copyWith({
    String? id,
    String? name,
    String? cnpj,
    String? logoUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return CompanyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      cnpj: cnpj ?? this.cnpj,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
