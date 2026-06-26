import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/create_permission_group_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/delete_permission_group_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/delete_user_profile_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_permission_groups_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_users_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/update_permission_group_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class UsersCubitUseCases {
  const UsersCubitUseCases({
    required this.getSessionUser,
    required this.getUsers,
    required this.getUserProfileById,
    required this.updateUserProfile,
    required this.deleteUserProfile,
    required this.getPermissionGroups,
    required this.createPermissionGroup,
    required this.updatePermissionGroup,
    required this.deletePermissionGroup,
  });

  final GetSessionUserUseCase getSessionUser;
  final GetUsersUseCase getUsers;
  final GetUserProfileByIdUseCase getUserProfileById;
  final UpdateUserProfileUseCase updateUserProfile;
  final DeleteUserProfileUseCase deleteUserProfile;
  final GetPermissionGroupsUseCase getPermissionGroups;
  final CreatePermissionGroupUseCase createPermissionGroup;
  final UpdatePermissionGroupUseCase updatePermissionGroup;
  final DeletePermissionGroupUseCase deletePermissionGroup;
}
