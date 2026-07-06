import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/routing/routes.dart';

class MockAppRouter extends Mock implements AppRouter {}

class MockAutoRouterDelegate extends AutoRouterDelegate {
  MockAutoRouterDelegate() : super(AppRouter());

  @override
  Widget build(BuildContext context) => Container();
}

class MockDefaultRouteParser extends Mock implements DefaultRouteParser {}

class MockPageRouteInfo extends PageRouteInfo<dynamic> {
  const MockPageRouteInfo() : super('MockRoute');
}
