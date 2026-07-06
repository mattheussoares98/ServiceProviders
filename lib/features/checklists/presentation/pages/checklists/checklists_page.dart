import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';

@RoutePage()
class ChecklistsPage extends StatelessWidget {
  const ChecklistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      appBar: BaseAppBar(title: 'Checklists'),
      body: Column(),
    );
  }
}
