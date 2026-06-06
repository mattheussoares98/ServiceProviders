import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
  });

  const UserEntity.empty() : id = '', name = '', email = '', isActive = false;
  final String id;
  final String name;
  final String email;
  final bool isActive;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    bool? isActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }

  MapDynamic toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'is_active': isActive,
  };

  @override
  List<Object?> get props => [id, name, email, isActive];
}
