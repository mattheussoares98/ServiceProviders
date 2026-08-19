import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';

void main() {
  group('ResponsiveListFlow Widget Tests', () {
    testWidgets('renders MasonryGridView on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveListFlow(
              itemCount: 4,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.byType(MasonryGridView), findsOneWidget);
    });

    testWidgets('renders SliverMasonryGrid in sliver mode on wide screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ResponsiveListFlow(
                  isSliver: true,
                  itemCount: 3,
                  itemBuilder: (context, index) => Text('Sliver Item $index'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Sliver Item 0'), findsOneWidget);
      expect(find.text('Sliver Item 1'), findsOneWidget);
      expect(find.text('Sliver Item 2'), findsOneWidget);
      expect(find.byType(SliverMasonryGrid), findsOneWidget);
    });
  });
}
