import 'package:cached_network_image/cached_network_image.dart';
import 'package:faker/faker.dart' show faker;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

void main() {
  group('BaseImageWidget Tests', () {
    testWidgets(
      'renders fallback widget when network source url is empty, whitespace-only, or "null"',
      (tester) async {
        // Empty string
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BaseImageWidget(source: BaseImageSource.network('')),
            ),
          ),
        );
        expect(find.byType(PlatformIcon), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);

        // Whitespace only
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BaseImageWidget(source: BaseImageSource.network('   ')),
            ),
          ),
        );
        expect(find.byType(PlatformIcon), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);

        // "null" string
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BaseImageWidget(source: BaseImageSource.network('null')),
            ),
          ),
        );
        expect(find.byType(PlatformIcon), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);

        // Invalid protocol
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BaseImageWidget(
                source: BaseImageSource.network('ftp://example.com/image.png'),
              ),
            ),
          ),
        );
        expect(find.byType(PlatformIcon), findsOneWidget);
        expect(find.byType(CachedNetworkImage), findsNothing);
      },
    );

    testWidgets('renders fallback widget when local source path is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BaseImageWidget(source: BaseImageSource.local('')),
          ),
        ),
      );

      expect(find.byType(PlatformIcon), findsOneWidget);
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
        expect(imageWidget.image, isA<ResizeImage>());
        final resizeImage = imageWidget.image as ResizeImage;
        expect(resizeImage.imageProvider, isA<AssetImage>());
        expect((resizeImage.imageProvider as AssetImage).assetName, assetPath);
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
        expect(imageWidget.image, isA<ResizeImage>());
        final resizeImage = imageWidget.image as ResizeImage;
        expect(resizeImage.imageProvider, isA<FileImage>());
        expect((resizeImage.imageProvider as FileImage).file.path, filePath);
      },
    );
  });
}
