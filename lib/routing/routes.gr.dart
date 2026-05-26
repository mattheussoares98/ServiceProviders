// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:clean_architecture/features/auth/presentation/pages/email_confirmation/email_confirmation_page.dart'
    as _i1;
import 'package:clean_architecture/features/auth/presentation/pages/login/login_page.dart'
    as _i3;
import 'package:clean_architecture/features/auth/presentation/pages/sign_up/sign_up_page.dart'
    as _i4;
import 'package:clean_architecture/features/home/presentation/pages/home_page/home_page.dart'
    as _i2;

/// generated route for
/// [_i1.EmailConfirmationPage]
class EmailConfirmationRoute extends _i5.PageRouteInfo<void> {
  const EmailConfirmationRoute({List<_i5.PageRouteInfo>? children})
    : super(EmailConfirmationRoute.name, initialChildren: children);

  static const String name = 'EmailConfirmationRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.EmailConfirmationPage();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.LoginPage]
class LoginRoute extends _i5.PageRouteInfo<void> {
  const LoginRoute({List<_i5.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.LoginPage();
    },
  );
}

/// generated route for
/// [_i4.SignUpPage]
class SignUpRoute extends _i5.PageRouteInfo<void> {
  const SignUpRoute({List<_i5.PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.SignUpPage();
    },
  );
}
