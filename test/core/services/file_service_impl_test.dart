// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:faker/faker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service_impl.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockFlutterImageCompressPlatform extends Mock
    implements FlutterImageCompressPlatform {}

class MockFlutterImageCompressValidator extends Mock
    implements FlutterImageCompressValidator {}

void main() {
  final faker = Faker();
  late MockImagePicker mockImagePicker;
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
  });

  setUp(() async {
    mockImagePicker = MockImagePicker();
    service = FileServiceImpl(imagePicker: mockImagePicker);

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
      expect(await service.fileExists('${tempDir.path}/nonexistent.txt'), isFalse);
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
    test('skips compression if webp and size is already small', () async {
      final source = File('${tempDir.path}/source.webp');
      await source.writeAsBytes(
        List.filled(100, 0),
      ); // 100 bytes is small (< 1MB)

      final result = await service.compressAndSaveImage(source.path);
      expect(result, isA<SuccessState<String>>());
      expect(result.data, contains('/attachments/'));
      expect(result.data, endsWith('.webp'));
      expect(File(result.data!).existsSync(), isTrue);
    });

    test(
      'performs compression if image is not webp or exceeds limit',
      () async {
        final source = File('${tempDir.path}/source.jpg');
        await source.writeAsBytes(List.filled(2 * 1024 * 1024, 0)); // 2MB

        final result = await service.compressAndSaveImage(source.path);
        expect(result, isA<SuccessState<String>>());
        expect(result.data, contains('/attachments/'));
        expect(result.data, endsWith('.webp'));
      },
    );
  });

  group('compressAndSaveVideo', () {
    test('executes compression and returns SuccessState(path)', () async {
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
      'returns SuccessState(true) when launching remote http/https URL succeeds',
      () async {
        urlLaunchSuccess = true;
        final result = await service.openFile('https://example.com/file.pdf');
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
      },
    );

    test('returns FailureState when launching remote URL fails', () async {
      urlLaunchSuccess = false;
      final result = await service.openFile('https://example.com/file.pdf');
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
}
