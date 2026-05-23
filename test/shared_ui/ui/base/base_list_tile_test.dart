import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BaseListTile Widget Tests', () {
    testWidgets('renders correct list tile type and displays title/icon', (
      tester,
    ) async {
      final isCupertino = PlatformUtil.isCupertino;
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaseListTile(
              title: 'Test Tile',
              platformIcon: const PlatformIcon(
                materialIcon: Icons.home,
                cupertinoIcon: CupertinoIcons.home,
              ),
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Verify title is rendered
      expect(find.text('Test Tile'), findsOneWidget);

      // Verify correct list tile type is returned and is clickable
      if (isCupertino) {
        expect(find.byType(CupertinoListTile), findsOneWidget);
        expect(find.byType(ListTile), findsNothing);

        await tester.tap(find.byType(CupertinoListTile));
      } else {
        expect(find.byType(ListTile), findsOneWidget);
        expect(find.byType(CupertinoListTile), findsNothing);

        await tester.tap(find.byType(ListTile));
      }

      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
