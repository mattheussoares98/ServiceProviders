import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

extension BuildContextExtension on BuildContext {
  double get statusHeight => MediaQuery.of(this).viewPadding.top;

  SystemUiOverlayStyle get systemOverlayStyle =>
      Theme.of(this).appBarTheme.systemOverlayStyle!;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  ThemeData get theme => Theme.of(this);

  bool get isCupertino => PlatformUtil.isCupertino;

  bool hasPermission(ActionPermission permission) {
    // Listen to the session user to trigger a rebuild when the logged-in user changes (permissions, group, etc.)
    select<SessionCubit, UserProfileEntity>((cubit) => cubit.state.user);

    // Evaluate the permission using UsersCubit
    return select<UsersCubit, bool>(
      (cubit) => cubit.hasPermission(permission.resource, permission.action),
    );
  }
}
