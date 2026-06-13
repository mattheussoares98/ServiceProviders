import 'package:cached_network_image/cached_network_image.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_image_widget.dart';
import 'package:faker/faker.dart' show faker;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BaseImageWidget Tests', () {
    testWidgets('renders errorWidget when network source url is empty', (
      tester,
    ) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaseImageWidget(
              source: BaseImageSource.network(''),
              errorWidget: Container(key: key),
            ),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('renders errorWidget when local source path is empty', (
      tester,
    ) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaseImageWidget(
              source: BaseImageSource.local(''),
              errorWidget: Container(key: key),
            ),
          ),
        ),
      );

      expect(find.byKey(key), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders CachedNetworkImage when network source url is valid', (
      tester,
    ) async {
      final url = faker.internet.httpsUrl();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaseImageWidget(source: BaseImageSource.network(url)),
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets(
      'renders Image.asset when local source path starts with assets/',
      (tester) async {
        final assetPath = 'assets/images/${faker.lorem.word()}.png';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BaseImageWidget(source: BaseImageSource.local(assetPath)),
            ),
          ),
        );

        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);
        final imageWidget = tester.widget<Image>(imageFinder);
        expect(imageWidget.image, isA<AssetImage>());
        expect((imageWidget.image as AssetImage).assetName, assetPath);
      },
    );

    testWidgets(
      'renders Image.file when local source path is a local file path',
      (tester) async {
        final filePath = '/path/to/${faker.lorem.word()}.png';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BaseImageWidget(source: BaseImageSource.local(filePath)),
            ),
          ),
        );

        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);
        final imageWidget = tester.widget<Image>(imageFinder);
        expect(imageWidget.image, isA<FileImage>());
        expect((imageWidget.image as FileImage).file.path, filePath);
      },
    );

    testWidgets(
      'shows full screen dialog when tapped and enableFullScreenOnTap is true',
      (tester) async {
        final url = faker.internet.httpsUrl();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BaseImageWidget(
                source: BaseImageSource.network(url),
                enableFullScreenOnTap: true,
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsNothing);

        await tester.tap(find.byType(BaseImageWidget));
        await tester.pumpAndSettle();

        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(find.byType(IconButton), findsNothing);
      },
    );
  });
}
