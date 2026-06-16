import 'package:clean_architecture/core/constants/api_endpoints.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:clean_architecture/features/assets/data/models/requests/asset_request_model.dart';
import 'package:clean_architecture/features/assets/data/models/responses/asset_model.dart';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late AssetsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = AssetsRemoteDataSourceImpl(httpClient: mockHttpClient);
  });

  final tAssetEntity = EntityFactory.makeAssetEntity();
  final tAssetModel = AssetModel.fromEntity(tAssetEntity);
  final tAssetRequest = AssetRequestModel.fromEntity(tAssetEntity);

  final tCompanyId = faker.guid.guid();
  final tId = faker.guid.guid();

  group('AssetsRemoteDataSourceImpl', () {
    test(
      'should return SuccessState<List<AssetResponseModel>> on 200 (getAssets)',
      () async {
        // Arrange
        final fakeResponse = {
          'data': [tAssetModel.toJson()],
          'message': 'Success',
        };

        when(
          () => mockHttpClient.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.assets),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.getAssets(tCompanyId);

        // Assert
        expect(result, isA<SuccessState<List<AssetModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tAssetModel.id);
        verify(
          () => mockHttpClient.get<dynamic>(
            ApiEndpoints.assets,
            queryParameters: {'company_id': tCompanyId},
          ),
        ).called(1);
      },
    );

    test(
      'should return SuccessState<AssetResponseModel> on 200 (getAssetById)',
      () async {
        // Arrange
        final fakeResponse = {
          'data': tAssetModel.toJson(),
          'message': 'Success',
        };

        when(() => mockHttpClient.get<dynamic>(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.assetById(tId)),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.getAssetById(tId);

        // Assert
        expect(result, isA<SuccessState<AssetModel>>());
        expect(result.data!.id, tAssetModel.id);
        verify(
          () => mockHttpClient.get<dynamic>(ApiEndpoints.assetById(tId)),
        ).called(1);
      },
    );

    test('should return SuccessState<AssetResponseModel> on create', () async {
      // Arrange
      final fakeResponse = {'data': tAssetModel.toJson(), 'message': 'Success'};

      when(
        () => mockHttpClient.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.assets),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.createAsset(tAssetRequest);

      // Assert
      expect(result, isA<SuccessState<AssetModel>>());
      expect(result.data!.id, tAssetModel.id);
    });

    test('should return SuccessState<AssetResponseModel> on update', () async {
      // Arrange
      final fakeResponse = {'data': tAssetModel.toJson(), 'message': 'Success'};

      when(
        () => mockHttpClient.put<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.assetById(tAssetRequest.id),
          ),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.updateAsset(tAssetRequest);

      // Assert
      expect(result, isA<SuccessState<AssetModel>>());
      expect(result.data!.id, tAssetModel.id);
    });

    test('should return SuccessState<void> on delete', () async {
      // Arrange
      final fakeResponse = {'message': 'Deleted'};

      when(() => mockHttpClient.delete<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.assetById(tAssetModel.id),
          ),
          data: fakeResponse,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.deleteAsset(tAssetModel.id);

      // Assert
      expect(result, isA<SuccessState<void>>());
    });
  });
}
