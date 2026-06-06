import 'package:clean_architecture/core/constants/api_endpoints.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:clean_architecture/features/categories/data/models/requests/category_request_model.dart';
import 'package:clean_architecture/features/categories/data/models/responses/category_response_model.dart';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late CategoriesRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = CategoriesRemoteDataSourceImpl(httpClient: mockHttpClient);
  });

  final tEntity = EntityFactory.makeCategoryEntity();
  final tModel = CategoryResponseModel.fromEntity(tEntity);
  final tRequest = CategoryRequestModel.fromEntity(tEntity);
  final tCompanyId = faker.guid.guid();

  group('CategoriesRemoteDataSourceImpl', () {
    group('getCategories', () {
      test(
        'should return SuccessState<List<CategoryResponseModel>> on 200',
        () async {
          // Arrange
          final fakeResponse = {
            'data': [tModel.toJson()],
            'message': 'Success',
          };

          when(
            () => mockHttpClient.get<dynamic>(
              any(),
              queryParameters: any(named: 'queryParameters'),
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.categories),
              data: fakeResponse,
              statusCode: 200,
            ),
          );

          // Act
          final result = await dataSource.getCategories(tCompanyId);

          // Assert
          expect(result, isA<SuccessState<List<CategoryResponseModel>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tModel.id);
          verify(
            () => mockHttpClient.get<dynamic>(
              ApiEndpoints.categories,
              queryParameters: {'company_id': tCompanyId},
            ),
          ).called(1);
        },
      );

      test('should return FailureState on error', () async {
        // Arrange
        when(
          () => mockHttpClient.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ApiEndpoints.categories),
            response: Response(
              requestOptions: RequestOptions(path: ApiEndpoints.categories),
              statusCode: 400,
            ),
          ),
        );

        // Act
        final result = await dataSource.getCategories(tCompanyId);

        // Assert
        expect(result, isA<FailureState<List<CategoryResponseModel>>>());
      });
    });

    group('createCategory', () {
      test(
        'should return SuccessState<CategoryResponseModel> on 200',
        () async {
          // Arrange
          final fakeResponse = {'data': tModel.toJson(), 'message': 'Success'};

          when(
            () => mockHttpClient.post<dynamic>(any(), data: any(named: 'data')),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ApiEndpoints.categories),
              data: fakeResponse,
              statusCode: 200,
            ),
          );

          // Act
          final result = await dataSource.createCategory(tRequest);

          // Assert
          expect(result, isA<SuccessState<CategoryResponseModel>>());
          expect(result.data!.id, tModel.id);
          verify(
            () => mockHttpClient.post<dynamic>(
              ApiEndpoints.categories,
              data: tRequest.toJson(),
            ),
          ).called(1);
        },
      );
    });

    group('updateCategory', () {
      test(
        'should return SuccessState<CategoryResponseModel> on 200',
        () async {
          // Arrange
          final fakeResponse = {'data': tModel.toJson(), 'message': 'Success'};

          when(
            () => mockHttpClient.put<dynamic>(any(), data: any(named: 'data')),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(
                path: ApiEndpoints.categoryById(tRequest.id),
              ),
              data: fakeResponse,
              statusCode: 200,
            ),
          );

          // Act
          final result = await dataSource.updateCategory(tRequest);

          // Assert
          expect(result, isA<SuccessState<CategoryResponseModel>>());
          expect(result.data!.id, tModel.id);
          verify(
            () => mockHttpClient.put<dynamic>(
              ApiEndpoints.categoryById(tRequest.id),
              data: tRequest.toJson(),
            ),
          ).called(1);
        },
      );
    });

    group('deleteCategory', () {
      test('should return SuccessState<void> on 200', () async {
        // Arrange
        final fakeResponse = {'message': 'Deleted'};

        when(() => mockHttpClient.delete<dynamic>(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
              path: ApiEndpoints.categoryById(tModel.id),
            ),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.deleteCategory(tModel.id);

        // Assert
        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockHttpClient.delete<dynamic>(
            ApiEndpoints.categoryById(tModel.id),
          ),
        ).called(1);
      });
    });
  });
}
