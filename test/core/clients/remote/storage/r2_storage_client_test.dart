import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/r2_storage_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show FunctionResponse, HttpMethod;

// ──────────────────────────────────────────
// Mocks
// ──────────────────────────────────────────

class MockDio extends Mock implements Dio {}

class MockFileService extends Mock implements FileService {}

class MockSupabaseDatabaseClient extends Mock
    implements SupabaseDatabaseClient {}

// ──────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────

Response<T> _mockResponse<T>(T data, {int statusCode = 200}) => Response(
  data: data,
  statusCode: statusCode,
  requestOptions: RequestOptions(),
);

void main() {
  final faker = Faker();
  late MockDio mockDio;
  late MockFileService mockFileService;
  late MockSupabaseDatabaseClient mockDatabase;
  late R2StorageClient client;

  setUp(() {
    mockDio = MockDio();
    mockFileService = MockFileService();
    mockDatabase = MockSupabaseDatabaseClient();
    client = R2StorageClient(
      fileService: mockFileService,
      database: mockDatabase,
      dio: mockDio,
    );
  });

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions());
    registerFallbackValue(HttpMethod.post);
  });

  // ──────────────────────────────────────────
  // StorageClient.buildObjectKey — pure function
  // ──────────────────────────────────────────

  group('StorageClient.buildObjectKey', () {
    test('produces the correct R2 object key', () {
      final companyId = faker.guid.guid();
      final workOrderId = faker.guid.guid();
      final uuid = faker.guid.guid();
      const ext = 'webp';

      final key = StorageClient.buildObjectKey(
        companyId: companyId,
        workOrderId: workOrderId,
        uuid: uuid,
        extension: ext,
      );

      expect(key, 'attachments/$companyId/$workOrderId/$uuid.$ext');
    });

    test('preserves extension exactly as provided', () {
      const ext = 'pdf';
      final key = StorageClient.buildObjectKey(
        companyId: faker.guid.guid(),
        workOrderId: faker.guid.guid(),
        uuid: faker.guid.guid(),
        extension: ext,
      );
      expect(key, endsWith('.$ext'));
    });

    test('always starts with attachments/ prefix', () {
      final key = StorageClient.buildObjectKey(
        companyId: faker.guid.guid(),
        workOrderId: faker.guid.guid(),
        uuid: faker.guid.guid(),
        extension: 'mp4',
      );
      expect(key, startsWith('attachments/'));
    });
  });

  // ──────────────────────────────────────────
  // getPresignedUploadUrl
  // ──────────────────────────────────────────

  group('getPresignedUploadUrl', () {
    test(
      'returns SuccessState with PresignedUrlResponse on valid response',
      () async {
        final objectKey = StorageClient.buildObjectKey(
          companyId: faker.guid.guid(),
          workOrderId: faker.guid.guid(),
          uuid: faker.guid.guid(),
          extension: 'webp',
        );
        final uploadUrl =
            'https://bucket.r2.dev/$objectKey?X-Amz-Signature=${faker.guid.guid()}';
        final fileKey = objectKey;
        final publicUrl = 'https://cdn.example.com/$objectKey';

        when(
          () => mockDatabase.invokeFunction(
            any(),
            method: any(named: 'method'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => FunctionResponse(
            status: 200,
            data: {
              'upload_url': uploadUrl,
              'file_key': fileKey,
              'public_url': publicUrl,
            },
          ),
        );

        final result = await client.getPresignedUploadUrl(objectKey);

        expect(result, isA<SuccessState<PresignedUrlResponse>>());
        final data = (result as SuccessState<PresignedUrlResponse>).data;
        expect(data!.uploadUrl, uploadUrl);
        expect(data.fileKey, fileKey);
        expect(data.publicUrl, publicUrl);
      },
    );

    test(
      'returns FailureState when database client throws an exception',
      () async {
        when(
          () => mockDatabase.invokeFunction(
            any(),
            method: any(named: 'method'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenThrow(Exception('Invoke failed'));

        final result = await client.getPresignedUploadUrl(faker.guid.guid());

        expect(result, isA<FailureState<PresignedUrlResponse>>());
      },
    );
  });

  // ──────────────────────────────────────────
  // uploadFile
  // ──────────────────────────────────────────

  group('uploadFile', () {
    late File tempFile;

    setUp(() async {
      // Create a real temp file — uploadFile reads it from disk.
      tempFile = await File(
        '${Directory.systemTemp.path}/test_upload_${faker.guid.guid()}.webp',
      ).writeAsBytes(List.filled(512, 0));
      when(
        () => mockFileService.readFileAsBytes(tempFile.path),
      ).thenAnswer((_) async => Uint8List.fromList(List.filled(512, 0)));
    });

    tearDown(() async {
      if (tempFile.existsSync()) await tempFile.delete();
    });

    test(
      'returns SuccessState with public URL stripped of query params',
      () async {
        final fileKey =
            'attachments/${faker.guid.guid()}/${faker.guid.guid()}/file.webp';
        final presignedUrl =
            'https://bucket.r2.dev/$fileKey?X-Amz-Expires=900&X-Amz-Signature=abc';

        when(
          () => mockDio.put<void>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
            queryParameters: any(named: 'queryParameters'),
            cancelToken: any(named: 'cancelToken'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
          ),
        ).thenAnswer((_) async => _mockResponse<void>(null));

        final result = await client.uploadFile(
          presignedUrl: presignedUrl,
          filePath: tempFile.path,
          mimeType: 'image/webp',
        );

        expect(result, isA<SuccessState<String>>());
        final publicUrl = (result as SuccessState<String>).data;
        // Public URL must not contain query params
        expect(publicUrl, isNot(contains('?')));
        expect(publicUrl, contains('bucket.r2.dev'));
        expect(publicUrl, contains(fileKey));
      },
    );

    test('returns FailureState when Dio throws during PUT', () async {
      when(
        () => mockDio.put<void>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
          queryParameters: any(named: 'queryParameters'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await client.uploadFile(
        presignedUrl: 'https://bucket.r2.dev/file.webp?sig=abc',
        filePath: tempFile.path,
        mimeType: 'image/webp',
      );

      expect(result, isA<FailureState<String>>());
    });

    test('returns FailureState when file does not exist', () async {
      final nonExistentPath = '/nonexistent/${faker.guid.guid()}.webp';
      when(
        () => mockFileService.readFileAsBytes(nonExistentPath),
      ).thenThrow(Exception('File not found'));

      final result = await client.uploadFile(
        presignedUrl: 'https://bucket.r2.dev/file.webp?sig=abc',
        filePath: nonExistentPath,
        mimeType: 'image/webp',
      );

      expect(result, isA<FailureState<String>>());
    });
  });
}
