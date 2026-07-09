import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  final faker = Faker();
  late MockSupabaseDatabaseClient mockDatabase;
  late AttachmentsRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(HttpMethod.post);
    registerFallbackValue(SupabaseFilter.eq('', ''));
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = AttachmentsRemoteDataSourceImpl(database: mockDatabase);
  });

  group('getPresignedUploadUrl', () {
    final tObjectKey = StorageClient.buildObjectKey(
      companyId: faker.guid.guid(),
      workOrderId: faker.guid.guid(),
      uuid: faker.guid.guid(),
      extension: 'webp',
    );
    final tUploadUrl = 'https://bucket.r2.dev/$tObjectKey?sig=abc';

    test(
      'should return SuccessState<PresignedUrlResponse> when Edge Function call is successful',
      () async {
        // Arrange
        final tPublicUrl = 'https://cdn.example.com/$tObjectKey';
        when(
          () => mockDatabase.invokeFunction(
            any(),
            method: any(named: 'method'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => FunctionResponse(
            data: {
              'upload_url': tUploadUrl,
              'file_key': tObjectKey,
              'public_url': tPublicUrl,
            },
            status: 200,
          ),
        );

        // Act
        final result = await dataSource.getPresignedUploadUrl(tObjectKey);

        // Assert
        expect(result, isA<SuccessState<PresignedUrlResponse>>());
        final data = (result as SuccessState<PresignedUrlResponse>).data;
        expect(data!.uploadUrl, tUploadUrl);
        expect(data.fileKey, tObjectKey);
        expect(data.publicUrl, tPublicUrl);
        verify(
          () => mockDatabase.invokeFunction(
            'generate_presigned_url',
            method: HttpMethod.post,
            body: {'object_key': tObjectKey},
          ),
        ).called(1);
      },
    );

    test('should return FailureState when Edge Function call throws exception', () async {
      // Arrange
      when(
        () => mockDatabase.invokeFunction(
          any(),
          method: any(named: 'method'),
          body: any(named: 'body'),
        ),
      ).thenThrow(const AuthException('Token expired'));

      // Act
      final result = await dataSource.getPresignedUploadUrl(tObjectKey);

      // Assert
      expect(result, isA<FailureState<PresignedUrlResponse>>());
    });
  });

  group('confirmUpload', () {
    final tAttachmentEntity = EntityFactory.makeAttachmentEntity();
    final tModel = AttachmentResponseModel.fromEntity(tAttachmentEntity);

    test(
      'should return SuccessState<bool>(true) when database upsert is successful',
      () async {
        // Arrange
        when(
          () => mockDatabase.upsert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.confirmUpload(tModel);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, isTrue);
        verify(
          () => mockDatabase.upsert(
            table: 'attachments',
            values: tModel.toJson(),
          ),
        ).called(1);
      },
    );

    test('should return FailureState when database upsert throws exception', () async {
      // Arrange
      when(
        () => mockDatabase.upsert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenThrow(const PostgrestException(message: 'Database error'));

      // Act
      final result = await dataSource.confirmUpload(tModel);

      // Assert
      expect(result, isA<FailureState<bool>>());
    });
  });

  group('getAttachmentsByWorkOrder', () {
    final tWorkOrderId = faker.guid.guid();
    final tAttachmentEntity = EntityFactory.makeAttachmentEntity();
    final tModel = AttachmentResponseModel.fromEntity(tAttachmentEntity);

    test(
      'should return SuccessState with list of models when database query is successful',
      () async {
        // Arrange
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tModel.toJson()]);

        // Act
        final result = await dataSource.getAttachmentsByWorkOrder(tWorkOrderId);

        // Assert
        expect(result, isA<SuccessState<List<AttachmentResponseModel>>>());
        final list =
            (result as SuccessState<List<AttachmentResponseModel>>).data;
        expect(list, hasLength(1));
        expect(list![0].id, tModel.id);
        expect(list[0].fileName, tModel.fileName);
        verify(
          () => mockDatabase.selectList(
            table: 'attachments',
            filters: [
              SupabaseFilter.eq('work_order_id', tWorkOrderId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      },
    );

    test('should return FailureState when database query throws exception', () async {
      // Arrange
      when(
        () => mockDatabase.selectList(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(const PostgrestException(message: 'Query error'));

      // Act
      final result = await dataSource.getAttachmentsByWorkOrder(tWorkOrderId);

      // Assert
      expect(result, isA<FailureState<List<AttachmentResponseModel>>>());
    });
  });

  group('deleteAttachment', () {
    final tAttachmentId = faker.guid.guid();

    test(
      'should return SuccessState<bool>(true) when database soft-deletion is successful',
      () async {
        // Arrange
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.deleteAttachment(tAttachmentId);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, isTrue);
        verify(
          () => mockDatabase.update(
            table: 'attachments',
            values: any(named: 'values'),
            filters: [SupabaseFilter.eq('id', tAttachmentId)],
          ),
        ).called(1);
      },
    );

    test('should return FailureState when database soft-deletion throws exception', () async {
      // Arrange
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(const PostgrestException(message: 'Deletion error'));

      // Act
      final result = await dataSource.deleteAttachment(tAttachmentId);

      // Assert
      expect(result, isA<FailureState<bool>>());
    });
  });
}
