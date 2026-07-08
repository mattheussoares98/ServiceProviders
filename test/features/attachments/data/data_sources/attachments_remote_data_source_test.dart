import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/constants/api_endpoints.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

Response<T> _mockResponse<T>(T data, {int statusCode = 200}) => Response(
  data: data,
  statusCode: statusCode,
  requestOptions: RequestOptions(),
);

void main() {
  final faker = Faker();
  late MockHttpClient mockHttpClient;
  late AttachmentsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = AttachmentsRemoteDataSourceImpl(httpClient: mockHttpClient);
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
      'should return SuccessState<PresignedUrlResponse> when API returns correct data',
      () async {
        // Arrange
        when(
          () =>
              mockHttpClient.post<MapDynamic>(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => _mockResponse<MapDynamic>({
            'data': {
              'upload_url': tUploadUrl,
              'file_key': tObjectKey,
            }
          }),
        );

        // Act
        final result = await dataSource.getPresignedUploadUrl(tObjectKey);

        // Assert
        expect(result, isA<SuccessState<PresignedUrlResponse>>());
        final data = (result as SuccessState<PresignedUrlResponse>).data;
        expect(data!.uploadUrl, tUploadUrl);
        expect(data.fileKey, tObjectKey);
      },
    );

    test('should return FailureState when API call fails', () async {
      // Arrange
      when(
        () => mockHttpClient.post<MapDynamic>(
          ApiEndpoints.presignedUploadUrl,
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(),
            data: {'message': 'Error requesting URL'},
          ),
        ),
      );

      // Act
      final result = await dataSource.getPresignedUploadUrl(tObjectKey);

      // Assert
      expect(result, isA<FailureState<PresignedUrlResponse>>());
    });
  });

  group('confirmUpload', () {
    final tAttachmentId = faker.guid.guid();
    final tRemoteUrl = faker.internet.httpsUrl();

    test(
      'should return SuccessState<bool>(true) when API update is successful',
      () async {
        // Arrange
        when(
          () => mockHttpClient.patch<void>(
            '${ApiEndpoints.attachments}/$tAttachmentId/confirm',
            data: {'remote_url': tRemoteUrl},
          ),
        ).thenAnswer((_) async => _mockResponse<void>(null));

        // Act
        final result = await dataSource.confirmUpload(
          attachmentId: tAttachmentId,
          remoteUrl: tRemoteUrl,
        );

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, isTrue);
      },
    );

    test('should return FailureState when API update fails', () async {
      // Arrange
      when(
        () => mockHttpClient.patch<void>(any(), data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await dataSource.confirmUpload(
        attachmentId: tAttachmentId,
        remoteUrl: tRemoteUrl,
      );

      // Assert
      expect(result, isA<FailureState<bool>>());
    });
  });

  group('getAttachmentsByWorkOrder', () {
    final tWorkOrderId = faker.guid.guid();
    final tAttachmentEntity = EntityFactory.makeAttachmentEntity();
    final tModel = AttachmentResponseModel.fromEntity(tAttachmentEntity);

    test(
      'should return SuccessState with list of models when API is successful',
      () async {
        // Arrange
        when(
          () => mockHttpClient.get<MapDynamic>(
            ApiEndpoints.attachments,
            queryParameters: {'work_order_id': tWorkOrderId},
          ),
        ).thenAnswer(
          (_) async => _mockResponse<MapDynamic>({
            'data': [tModel.toJson()]
          }),
        );

        // Act
        final result = await dataSource.getAttachmentsByWorkOrder(tWorkOrderId);

        // Assert
        expect(result, isA<SuccessState<List<AttachmentResponseModel>>>());
        final list =
            (result as SuccessState<List<AttachmentResponseModel>>).data;
        expect(list, hasLength(1));
        expect(list![0].id, tModel.id);
        expect(list[0].fileName, tModel.fileName);
      },
    );

    test('should return FailureState when API call fails', () async {
      // Arrange
      when(
        () => mockHttpClient.get<MapDynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await dataSource.getAttachmentsByWorkOrder(tWorkOrderId);

      // Assert
      expect(result, isA<FailureState<List<AttachmentResponseModel>>>());
    });
  });

  group('deleteAttachment', () {
    final tAttachmentId = faker.guid.guid();

    test(
      'should return SuccessState<bool>(true) when API deletion is successful',
      () async {
        // Arrange
        when(
          () => mockHttpClient.delete<void>(
            '${ApiEndpoints.attachments}/$tAttachmentId',
          ),
        ).thenAnswer((_) async => _mockResponse<void>(null));

        // Act
        final result = await dataSource.deleteAttachment(tAttachmentId);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect((result as SuccessState<bool>).data, isTrue);
      },
    );

    test('should return FailureState when API deletion fails', () async {
      // Arrange
      when(
        () => mockHttpClient.delete<void>(any()),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act
      final result = await dataSource.deleteAttachment(tAttachmentId);

      // Assert
      expect(result, isA<FailureState<bool>>());
    });
  });
}

