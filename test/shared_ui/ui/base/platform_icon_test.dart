import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

void main() {
  group('PlatformIcon Widget Tests', () {
    testWidgets('renders the appropriate icon for the platform', (
      tester,
    ) async {
      final isCupertino = PlatformUtil.isCupertino;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlatformIcon(
              materialIcon: Icons.star,
              cupertinoIcon: CupertinoIcons.star,
            ),
          ),
        ),
      );

      if (isCupertino) {
        expect(find.byIcon(CupertinoIcons.star), findsOneWidget);
        expect(find.byIcon(Icons.star), findsNothing);
      } else {
        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.star), findsNothing);
      }
    });

    testWidgets('PlatformIcon.back factory renders the correct back icon', (
      tester,
    ) async {
      final isCupertino = PlatformUtil.isCupertino;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PlatformIcon.back())),
      );

      if (isCupertino) {
        expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
      } else {
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      }
    });

    testWidgets('PlatformIcon.share factory renders the correct share icon', (
      tester,
    ) async {
      final isCupertino = PlatformUtil.isCupertino;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PlatformIcon.share())),
      );

      if (isCupertino) {
        expect(find.byIcon(CupertinoIcons.share), findsOneWidget);
      } else {
        expect(find.byIcon(Icons.share), findsOneWidget);
      }
    });

    testWidgets(
      'PlatformIcon.settings factory renders the correct settings icon',
      (tester) async {
        final isCupertino = PlatformUtil.isCupertino;

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: PlatformIcon.settings())),
        );

        if (isCupertino) {
          expect(find.byIcon(CupertinoIcons.settings), findsOneWidget);
        } else {
          expect(find.byIcon(Icons.settings), findsOneWidget);
        }
      },
    );

    testWidgets('PlatformIcon.delete factory renders the correct delete icon', (
      tester,
    ) async {
      final isCupertino = PlatformUtil.isCupertino;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PlatformIcon.delete())),
      );

      if (isCupertino) {
        expect(find.byIcon(CupertinoIcons.trash), findsOneWidget);
      } else {
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      }
    });

    testWidgets('PlatformIcon.info factory renders the correct info icon', (
      tester,
    ) async {
      final isCupertino = PlatformUtil.isCupertino;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PlatformIcon.info())),
      );

      if (isCupertino) {
        expect(find.byIcon(CupertinoIcons.info), findsOneWidget);
      } else {
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      }
    });

    testWidgets('applies padding adaptively if specified', (tester) async {
      final isCupertino = PlatformUtil.isCupertino;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlatformIcon(
              materialIcon: Icons.add,
              cupertinoIcon: CupertinoIcons.add,
            ),
          ),
        ),
      );

      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsOneWidget);

      final paddingWidget = tester.widget<Padding>(paddingFinder);
      if (isCupertino) {
        expect(paddingWidget.padding, const EdgeInsets.all(16));
      } else {
        expect(paddingWidget.padding, const EdgeInsets.all(8));
      }
    });
  });
}
