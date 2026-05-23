import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePagePage extends StatelessWidget {
  const HomePagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: BaseAppBar(title: 'HomePage'.hardcoded),
      body: const SafeArea(child: Column()),
    );
  }
}
