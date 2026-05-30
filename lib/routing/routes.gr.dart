// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:clean_architecture/features/auth/presentation/pages/change_password/change_password_page.dart'
    as _i1;
import 'package:clean_architecture/features/auth/presentation/pages/email_confirmation/email_confirmation_page.dart'
    as _i2;
import 'package:clean_architecture/features/auth/presentation/pages/login/login_page.dart'
    as _i4;
import 'package:clean_architecture/features/auth/presentation/pages/sign_up/sign_up_page.dart'
    as _i5;
import 'package:clean_architecture/features/home/presentation/pages/home_page/home_page.dart'
    as _i3;

/// generated route for
/// [_i1.ChangePasswordPage]
class ChangePasswordRoute extends _i6.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i6.PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.ChangePasswordPage();
    },
  );
}

/// generated route for
/// [_i2.EmailConfirmationPage]
class EmailConfirmationRoute extends _i6.PageRouteInfo<void> {
  const EmailConfirmationRoute({List<_i6.PageRouteInfo>? children})
    : super(EmailConfirmationRoute.name, initialChildren: children);

  static const String name = 'EmailConfirmationRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.EmailConfirmationPage();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i6.PageRouteInfo<void> {
  const HomeRoute({List<_i6.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.LoginPage]
class LoginRoute extends _i6.PageRouteInfo<void> {
  const LoginRoute({List<_i6.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.LoginPage();
    },
  );
}

/// generated route for
/// [_i5.SignUpPage]
class SignUpRoute extends _i6.PageRouteInfo<void> {
  const SignUpRoute({List<_i6.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.SignUpPage();
    },
  );
}
