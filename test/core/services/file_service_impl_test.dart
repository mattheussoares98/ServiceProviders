import 'dart:io';

import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service_impl.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../testing/mocks/client_mocks.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockFlutterImageCompressPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FlutterImageCompressPlatform {}

class MockFlutterImageCompressValidator extends Mock
    implements FlutterImageCompressValidator {}

class MockFilePicker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePicker {}

void main() {
  final faker = Faker();
  late MockImagePicker mockImagePicker;
  late MockHttpClient mockHttpClient;
  late MockFilePicker mockFilePicker;
  late FileServiceImpl service;
  late Directory tempDir;
  late bool urlLaunchSuccess;
  late int openFileResultType;
  late String openFileResultMessage;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final fileType in FileType.values) {
      registerFallbackValue(fileType);
    }
    registerFallbackValue(CompressFormat.webp);
    registerFallbackValue(CompressFormat.jpeg);
  });

  setUp(() async {
    mockImagePicker = MockImagePicker();
    mockHttpClient = MockHttpClient();
    mockFilePicker = MockFilePicker();
    FilePicker.platform = mockFilePicker;
    service = FileServiceImpl(
      imagePicker: mockImagePicker,
      client: mockHttpClient,
    );

    tempDir = await Directory.systemTemp.createTemp('file_service_test_');

    // Stub FlutterImageCompressPlatform
    final mockPlatform = MockFlutterImageCompressPlatform();
    final mockValidator = MockFlutterImageCompressValidator();
    when(() => mockPlatform.validator).thenReturn(mockValidator);
    when(
      () => mockValidator.checkSupportPlatform(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockPlatform.compressAndGetFile(
        any(),
        any(),
        minWidth: any(named: 'minWidth'),
        minHeight: any(named: 'minHeight'),
        inSampleSize: any(named: 'inSampleSize'),
        quality: any(named: 'quality'),
        rotate: any(named: 'rotate'),
        autoCorrectionAngle: any(named: 'autoCorrectionAngle'),
        format: any(named: 'format'),
        keepExif: any(named: 'keepExif'),
        numberOfRetries: any(named: 'numberOfRetries'),
      ),
    ).thenAnswer((invocation) async {
      final targetPath = invocation.positionalArguments[1] as String;
      final file = File(targetPath);
      if (!file.existsSync()) {
        await file.create(recursive: true);
        await file.writeAsBytes(List.filled(100, 0));
      }
      return XFile(targetPath);
    });

    FlutterImageCompressPlatform.instance = mockPlatform;

    // Mock path_provider channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );

    // Mock url_launcher channel
    urlLaunchSuccess = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          (methodCall) async {
            if (methodCall.method == 'canLaunch') {
              return true;
            }
            if (methodCall.method == 'launch') {
              return urlLaunchSuccess;
            }
            return null;
          },
        );

    // Mock open_file channel
    openFileResultType = 0; // 0 = ResultType.done
    openFileResultMessage = 'done';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('open_file'), (
          methodCall,
        ) async {
          if (methodCall.method == 'open_file') {
            return {
              'type': openFileResultType,
              'message': openFileResultMessage,
            };
          }
          return null;
        });

    // Mock ffmpeg_kit channel
    String? ffmpegDestPath;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.arthenica.com/ffmpeg_kit'),
          (methodCall) async {
            if (methodCall.method == 'ffmpegSession') {
              final args = methodCall.arguments as Map;
              final commandArgs = args['arguments'] as List;
              ffmpegDestPath = commandArgs.last.toString().replaceAll('"', '');
              return {'sessionId': 1, 'arguments': commandArgs};
            }
            if (methodCall.method == 'ffmpegSessionExecute' ||
                methodCall.method == 'ffmpegKitExecute') {
              if (ffmpegDestPath != null) {
                final file = File(ffmpegDestPath!);
                if (!file.existsSync()) {
                  await file.create(recursive: true);
                  await file.writeAsBytes(List.filled(500, 0));
                }
              }
              return null;
            }
            if (methodCall.method == 'abstractSessionGetReturnCode') {
              return 0; // success
            }
            return null;
          },
        );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('getMimeType', () {
    test('should return correct MIME types for extension mapping', () {
      expect(service.getMimeType('test.jpg'), 'image/jpeg');
      expect(service.getMimeType('test.jpeg'), 'image/jpeg');
      expect(service.getMimeType('test.png'), 'image/png');
      expect(service.getMimeType('test.webp'), 'image/webp');
      expect(service.getMimeType('test.heic'), 'image/heic');
      expect(service.getMimeType('test.mp4'), 'video/mp4');
      expect(service.getMimeType('test.mov'), 'video/quicktime');
      expect(service.getMimeType('test.pdf'), 'application/pdf');
      expect(
        service.getMimeType('test.docx'),
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
      expect(
        service.getMimeType('test.xlsx'),
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      expect(service.getMimeType('test.xyz'), 'application/octet-stream');
    });
  });

  group('takePhoto', () {
    test('returns path when ImagePicker successfully grabs a photo', () async {
      final fakePath = '${tempDir.path}/${faker.guid.guid()}.jpg';
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => XFile(fakePath));

      final result = await service.takePhoto();
      expect(result, fakePath);
    });

    test('returns null when ImagePicker returns null (cancelled)', () async {
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => null);

      final result = await service.takePhoto();
      expect(result, isNull);
    });
  });

  group('recordVideo', () {
    test('returns path when ImagePicker successfully records video', () async {
      final fakePath = '${tempDir.path}/${faker.guid.guid()}.mp4';
      when(
        () => mockImagePicker.pickVideo(
          source: ImageSource.camera,
          maxDuration: any(named: 'maxDuration'),
        ),
      ).thenAnswer((_) async => XFile(fakePath));

      final result = await service.recordVideo();
      expect(result, fakePath);
    });

    test('returns null when user cancels video recording', () async {
      when(
        () => mockImagePicker.pickVideo(
          source: ImageSource.camera,
          maxDuration: any(named: 'maxDuration'),
        ),
      ).thenAnswer((_) async => null);

      final result = await service.recordVideo();
      expect(result, isNull);
    });
  });

  group('pickMediaFromGallery', () {
    test('returns list of paths when user picks multiple files', () async {
      final fakePaths = [
        '${tempDir.path}/${faker.guid.guid()}.jpg',
        '${tempDir.path}/${faker.guid.guid()}.png',
      ];
      when(
        () => mockImagePicker.pickMultipleMedia(),
      ).thenAnswer((_) async => fakePaths.map(XFile.new).toList());

      final result = await service.pickMediaFromGallery();
      final expected = fakePaths
          .map((p) => (path: p, name: p.split('/').last, bytes: null))
          .toList();
      expect(result, expected);
    });

    test('returns null when user cancels gallery pick', () async {
      when(
        () => mockImagePicker.pickMultipleMedia(),
      ).thenAnswer((_) async => []);

      final result = await service.pickMediaFromGallery();
      expect(result, isNull);
    });

    test('returns single file path when multiple = false', () async {
      final fakePath = '${tempDir.path}/${faker.guid.guid()}.jpg';
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 100,
        ),
      ).thenAnswer((_) async => XFile(fakePath));

      final result = await service.pickMediaFromGallery(multiple: false);
      expect(result, [
        (path: fakePath, name: fakePath.split('/').last, bytes: null),
      ]);
    });

    test(
      'returns null when user cancels single file pick (multiple = false)',
      () async {
        when(
          () => mockImagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 100,
          ),
        ).thenAnswer((_) async => null);

        final result = await service.pickMediaFromGallery(multiple: false);
        expect(result, isNull);
      },
    );
  });

  group('pickDocuments', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test(
      'restricts allowedExtensions to document types only on mobile platform',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        final fileName = faker.lorem.word();
        final filePath = '${tempDir.path}/$fileName';
        when(
          () => mockFilePicker.pickFiles(
            allowMultiple: any(named: 'allowMultiple'),
            type: any(named: 'type'),
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer(
          (_) async => FilePickerResult([
            PlatformFile(name: fileName, path: filePath, size: 100),
          ]),
        );

        final result = await service.pickDocuments();

        expect(result, [(path: filePath, name: fileName, bytes: null)]);
        verify(
          () => mockFilePicker.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: ['pdf', 'docx', 'xlsx'],
          ),
        ).called(1);
      },
    );

    test(
      'expands allowedExtensions to include images and videos on macOS/desktop platform',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final fileName = faker.lorem.word();
        final filePath = '${tempDir.path}/$fileName';
        when(
          () => mockFilePicker.pickFiles(
            allowMultiple: any(named: 'allowMultiple'),
            type: any(named: 'type'),
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer(
          (_) async => FilePickerResult([
            PlatformFile(name: fileName, path: filePath, size: 100),
          ]),
        );

        final result = await service.pickDocuments();

        expect(result, [(path: filePath, name: fileName, bytes: null)]);
        verify(
          () => mockFilePicker.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: [
              'pdf',
              'docx',
              'xlsx',
              'jpg',
              'jpeg',
              'png',
              'webp',
              'heic',
              'mp4',
              'mov',
            ],
          ),
        ).called(1);
      },
    );

    test('returns null when user cancels document picker', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      when(
        () => mockFilePicker.pickFiles(
          allowMultiple: any(named: 'allowMultiple'),
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => null);

      final result = await service.pickDocuments();

      expect(result, isNull);
    });
  });

  group('readFileAsBytes', () {
    test('returns correct bytes of a file', () async {
      final file = File('${tempDir.path}/test_bytes.txt');
      final bytes = [10, 20, 30, 40];
      await file.writeAsBytes(bytes);

      final result = await service.readFileAsBytes(file.path);
      expect(result, bytes);
    });
  });

  group('fileExists', () {
    test('returns true if file exists', () async {
      final file = File('${tempDir.path}/exist.txt');
      await file.writeAsBytes([0]);
      expect(await service.fileExists(file.path), isTrue);
    });

    test('returns false if file does not exist', () async {
      expect(
        await service.fileExists('${tempDir.path}/nonexistent.txt'),
        isFalse,
      );
    });
  });

  group('getFileSizeBytes', () {
    test('returns correct length of a file', () async {
      final file = File('${tempDir.path}/test_file.txt');
      await file.writeAsBytes([1, 2, 3, 4, 5]);

      final size = await service.getFileSizeBytes(file.path);
      expect(size, 5);
    });
  });

  group('deleteLocalFile', () {
    test('deletes file if it exists and returns SuccessState(true)', () async {
      final file = File('${tempDir.path}/test_delete.txt');
      await file.writeAsBytes([1]);
      expect(file.existsSync(), isTrue);

      final result = await service.deleteLocalFile(file.path);
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
      expect(file.existsSync(), isFalse);
    });

    test('returns SuccessState(true) if file does not exist', () async {
      final result = await service.deleteLocalFile(
        '${tempDir.path}/nonexistent.txt',
      );
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, isTrue);
    });
  });

  group('copyFileToSandbox', () {
    test('copies file to documents sandbox directory', () async {
      final source = File('${tempDir.path}/source.pdf');
      await source.writeAsBytes([10, 20]);

      final result = await service.copyFileToSandbox(source.path, 'copied.pdf');
      expect(result, isA<SuccessState<String>>());
      expect(result.data, endsWith('/attachments/copied.pdf'));

      final copiedFile = File(result.data!);
      expect(copiedFile.existsSync(), isTrue);
      expect(await copiedFile.length(), 2);
    });

    test('returns FailureState when an error occurs during copy', () async {
      final result = await service.copyFileToSandbox(
        '${tempDir.path}/invalid.pdf',
        'copied.pdf',
      );
      expect(result, isA<FailureState<String>>());
    });
  });

  group('compressAndSaveImage', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test(
      'copies file directly to sandbox on desktop platforms without compression',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        final source = File('${tempDir.path}/source.png');
        await source.writeAsBytes(List.filled(2 * 1024 * 1024, 0));

        final result = await service.compressAndSaveImage(source.path);
        expect(result, isA<SuccessState<String>>());
        expect(result.data, contains('/attachments/'));
        expect(result.data, endsWith('.png'));
        expect(File(result.data!).existsSync(), isTrue);
      },
    );

    test('compresses to webp on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final source = File('${tempDir.path}/source.jpg');
      await source.writeAsBytes(List.filled(2 * 1024 * 1024, 0)); // 2MB

      final result = await service.compressAndSaveImage(source.path);
      expect(result, isA<SuccessState<String>>());
      expect(result.data, contains('/attachments/'));
      expect(result.data, endsWith('.webp'));
    });

    test('compresses to webp on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final source = File('${tempDir.path}/source.jpg');
      await source.writeAsBytes(List.filled(2 * 1024 * 1024, 0)); // 2MB

      final result = await service.compressAndSaveImage(source.path);
      expect(result, isA<SuccessState<String>>());
      expect(result.data, contains('/attachments/'));
      expect(result.data, endsWith('.webp'));
    });
  });

  group('compressAndSaveVideo', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('copies video directly to sandbox on desktop platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final source = File('${tempDir.path}/source.mov');
      await source.writeAsBytes(List.filled(5 * 1024 * 1024, 0));

      final result = await service.compressAndSaveVideo(source.path);
      expect(result, isA<SuccessState<String>>());
      expect(result.data, contains('/attachments/'));
      expect(result.data, endsWith('.mov'));
      expect(File(result.data!).existsSync(), isTrue);
    });

    test('executes compression on mobile platform (Android)', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final source = File('${tempDir.path}/source.mov');
      await source.writeAsBytes(List.filled(5 * 1024 * 1024, 0));

      final result = await service.compressAndSaveVideo(source.path);
      expect(result, isA<SuccessState<String>>());
      expect(result.data, contains('/attachments/'));
      expect(result.data, endsWith('.mp4'));
      expect(File(result.data!).existsSync(), isTrue);
    });
  });

  group('getOrCreateVideoThumbnail', () {
    test('generates video thumbnail and returns SuccessState(path)', () async {
      final source = '${tempDir.path}/video.mp4';
      final result = await service.getOrCreateVideoThumbnail(source);
      expect(result, isA<SuccessState<String>>());
      expect(result.data, contains('/attachments/thumb_video.jpg'));
      expect(File(result.data!).existsSync(), isTrue);
    });
  });

  group('openFile', () {
    test(
      'opens cached file directly from sandbox without downloading if already present',
      () async {
        const fileName = 'test_document.pdf';
        final attachmentsDir = Directory('${tempDir.path}/attachments');
        await attachmentsDir.create(recursive: true);
        final cachedFile = File('${attachmentsDir.path}/$fileName');
        await cachedFile.writeAsBytes([1, 2, 3]);

        openFileResultType = 0; // ResultType.done
        final result = await service.openFile('https://example.com/$fileName');

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        // Verify mockHttpClient.download was NOT called because file was cached
        verifyNever(
          () => mockHttpClient.download(any<String>(), any<dynamic>()),
        );
      },
    );

    test(
      'downloads remote document and opens via OpenFilex when not already cached',
      () async {
        when(
          () => mockHttpClient.download(any<String>(), any<dynamic>()),
        ).thenAnswer((invocation) async {
          final destPath = invocation.positionalArguments[1] as String;
          final file = File(destPath);
          await file.create(recursive: true);
          await file.writeAsBytes([1, 2, 3]);
          return Response(requestOptions: RequestOptions(), statusCode: 200);
        });

        openFileResultType = 0; // ResultType.done
        final result = await service.openFile(
          'https://example.com/remote_file.pdf',
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockHttpClient.download(
            'https://example.com/remote_file.pdf',
            any<dynamic>(),
          ),
        ).called(1);
      },
    );

    test(
      'falls back to external browser when downloading remote document fails but URL launch succeeds',
      () async {
        when(
          () => mockHttpClient.download(any<String>(), any<dynamic>()),
        ).thenAnswer(
          (_) async =>
              Response(requestOptions: RequestOptions(), statusCode: 500),
        );

        urlLaunchSuccess = true;
        final result = await service.openFile(
          'https://example.com/remote_file_fail.pdf',
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
      },
    );

    test(
      'returns SuccessState(true) when launching remote http/https URL directly succeeds',
      () async {
        urlLaunchSuccess = true;
        final result = await service.openFile('https://example.com/page');
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
      },
    );

    test('returns FailureState when launching remote URL fails', () async {
      when(
        () => mockHttpClient.download(any<String>(), any<dynamic>()),
      ).thenAnswer(
        (_) async =>
            Response(requestOptions: RequestOptions(), statusCode: 500),
      );
      urlLaunchSuccess = false;
      final result = await service.openFile(
        'https://example.com/file_fail.pdf',
      );
      expect(result, isA<FailureState<bool>>());
    });

    test('returns FailureState if local file does not exist', () async {
      final result = await service.openFile('${tempDir.path}/nonexistent.pdf');
      expect(result, isA<FailureState<bool>>());
      expect(result.message, contains('Arquivo local não encontrado'));
    });

    test(
      'returns SuccessState(true) when opening existing local file succeeds',
      () async {
        final file = File('${tempDir.path}/local.pdf');
        await file.writeAsBytes([1, 2, 3]);

        openFileResultType = 0; // ResultType.done
        final result = await service.openFile(file.path);
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
      },
    );
  });

  group('downloadUrlToSandbox', () {
    test(
      'downloads file via HttpClient and returns SuccessState(path)',
      () async {
        when(
          () => mockHttpClient.download(any<String>(), any<dynamic>()),
        ).thenAnswer(
          (_) async =>
              Response(requestOptions: RequestOptions(), statusCode: 200),
        );

        final url = faker.internet.httpsUrl();
        final fileName = '${faker.guid.guid()}.jpg';
        final result = await service.downloadUrlToSandbox(url, fileName);

        expect(result, isA<SuccessState<String>>());
        expect(result.data, contains('/attachments/$fileName'));
        verify(() => mockHttpClient.download(url, any<dynamic>())).called(1);
      },
    );
  });
}
