import 'package:faker/faker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service_impl.dart';

// ──────────────────────────────────────────
// Mocks
// ──────────────────────────────────────────

class MockImagePicker extends Mock implements ImagePicker {}

class MockFilePicker extends Mock implements FilePicker {}

// ──────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────

FileServiceImpl _buildService({
  MockImagePicker? imagePicker,
  MockFilePicker? filePicker,
}) {
  return FileServiceImpl(
    imagePicker: imagePicker ?? MockImagePicker(),
    filePicker: filePicker ?? MockFilePicker(),
  );
}

void main() {
  final faker = Faker();
  late MockImagePicker mockImagePicker;
  late MockFilePicker mockFilePicker;
  late FileServiceImpl service;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockFilePicker = MockFilePicker();
    service = _buildService(
      imagePicker: mockImagePicker,
      filePicker: mockFilePicker,
    );
  });

  setUpAll(() {
    registerFallbackValue(FileType.any);
  });

  // ──────────────────────────────────────────
  // getMimeType — pure function, no mocking needed
  // ──────────────────────────────────────────

  group('getMimeType', () {
    test('returns image/jpeg for .jpg', () {
      expect(service.getMimeType('photo.jpg'), 'image/jpeg');
    });

    test('returns image/jpeg for .jpeg', () {
      expect(service.getMimeType('photo.jpeg'), 'image/jpeg');
    });

    test('returns image/png for .png', () {
      expect(service.getMimeType('photo.png'), 'image/png');
    });

    test('returns image/webp for .webp', () {
      expect(service.getMimeType('photo.webp'), 'image/webp');
    });

    test('returns image/heic for .heic', () {
      expect(service.getMimeType('photo.heic'), 'image/heic');
    });

    test('returns video/mp4 for .mp4', () {
      expect(service.getMimeType('video.mp4'), 'video/mp4');
    });

    test('returns video/quicktime for .mov', () {
      expect(service.getMimeType('video.mov'), 'video/quicktime');
    });

    test('returns application/pdf for .pdf', () {
      expect(service.getMimeType('document.pdf'), 'application/pdf');
    });

    test('returns correct MIME for .docx', () {
      expect(
        service.getMimeType('document.docx'),
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      );
    });

    test('returns correct MIME for .xlsx', () {
      expect(
        service.getMimeType('document.xlsx'),
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    });

    test('returns application/octet-stream for unknown extension', () {
      expect(service.getMimeType('file.unknown'), 'application/octet-stream');
    });

    test('is case-insensitive — .JPG returns image/jpeg', () {
      expect(service.getMimeType('photo.JPG'), 'image/jpeg');
    });

    test('works with full paths', () {
      final path = '/storage/emulated/0/${faker.lorem.word()}.pdf';
      expect(service.getMimeType(path), 'application/pdf');
    });
  });

  // ──────────────────────────────────────────
  // takePhoto
  // ──────────────────────────────────────────

  group('takePhoto', () {
    test('returns file path when camera returns a photo', () async {
      final fakePath = '/tmp/${faker.guid.guid()}.jpg';
      when(
        () => mockImagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => XFile(fakePath));

      final result = await service.takePhoto();

      expect(result, fakePath);
    });

    test('returns null when user cancels the camera', () async {
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

  // ──────────────────────────────────────────
  // recordVideo
  // ──────────────────────────────────────────

  group('recordVideo', () {
    test('returns file path when camera returns a video', () async {
      final fakePath = '/tmp/${faker.guid.guid()}.mp4';
      when(
        () => mockImagePicker.pickVideo(
          source: ImageSource.camera,
          maxDuration: any(named: 'maxDuration'),
        ),
      ).thenAnswer((_) async => XFile(fakePath));

      final result = await service.recordVideo();

      expect(result, fakePath);
    });

    test('returns null when user cancels the video recording', () async {
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

  // ──────────────────────────────────────────
  // pickMediaFromGallery
  // ──────────────────────────────────────────

  group('pickMediaFromGallery', () {
    test('returns list of paths when user selects media', () async {
      final paths = List.generate(
        3,
        (_) => '/gallery/${faker.guid.guid()}.jpg',
      );
      when(
        () => mockImagePicker.pickMultipleMedia(),
      ).thenAnswer((_) async => paths.map(XFile.new).toList());

      final result = await service.pickMediaFromGallery();

      expect(result, paths);
    });

    test('returns null when user selects nothing (empty list)', () async {
      when(
        () => mockImagePicker.pickMultipleMedia(),
      ).thenAnswer((_) async => []);

      final result = await service.pickMediaFromGallery();

      expect(result, isNull);
    });
  });

  // ──────────────────────────────────────────
  // pickDocuments
  // ──────────────────────────────────────────

  group('pickDocuments', () {
    test('returns list of paths when user selects documents', () async {
      final paths = [
        '/docs/${faker.guid.guid()}.pdf',
        '/docs/${faker.guid.guid()}.docx',
        '/docs/${faker.guid.guid()}.xlsx',
      ];
      final platformFiles = paths
          .map(
            (p) => PlatformFile(name: p.split('/').last, size: 1024, path: p),
          )
          .toList();

      when(
        () => mockFilePicker.pickFiles(
          allowMultiple: any(named: 'allowMultiple'),
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => FilePickerResult(platformFiles));

      final result = await service.pickDocuments();

      expect(result, paths);
    });

    test('returns null when user cancels the file picker', () async {
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

    test('returns null when picker result has no files', () async {
      when(
        () => mockFilePicker.pickFiles(
          allowMultiple: any(named: 'allowMultiple'),
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => const FilePickerResult([]));

      final result = await service.pickDocuments();

      expect(result, isNull);
    });

    test('filters out files with null paths', () async {
      final validPath = '/docs/${faker.guid.guid()}.pdf';
      final platformFiles = [
        PlatformFile(name: 'valid.pdf', size: 1024, path: validPath),
        PlatformFile(name: 'no_path.pdf', size: 1024),
      ];

      when(
        () => mockFilePicker.pickFiles(
          allowMultiple: any(named: 'allowMultiple'),
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => FilePickerResult(platformFiles));

      final result = await service.pickDocuments();

      expect(result, [validPath]);
    });
  });

  // ──────────────────────────────────────────
  // deleteLocalFile
  // ──────────────────────────────────────────

  group('deleteLocalFile', () {
    test('returns SuccessState(true) when file does not exist', () async {
      // A non-existent path — existsSync() returns false, so delete is skipped
      final result = await service.deleteLocalFile(
        '/nonexistent/${faker.guid.guid()}.pdf',
      );

      expect(result, isA<SuccessState<bool>>());
    });
  });
}
