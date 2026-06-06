import 'package:clean_architecture/core/constants/api_endpoints.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:clean_architecture/features/locations/data/models/requests/area_request_model.dart';
import 'package:clean_architecture/features/locations/data/models/requests/location_request_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/area_response_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/location_response_model.dart';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late LocationsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = LocationsRemoteDataSourceImpl(httpClient: mockHttpClient);
  });

  final tLocationEntity = EntityFactory.makeLocationEntity();
  final tLocationModel = LocationResponseModel.fromEntity(tLocationEntity);
  final tLocationRequest = LocationRequestModel.fromEntity(tLocationEntity);

  final tAreaEntity = EntityFactory.makeAreaEntity();
  final tAreaModel = AreaResponseModel.fromEntity(tAreaEntity);
  final tAreaRequest = AreaRequestModel.fromEntity(tAreaEntity);

  final tCompanyId = faker.guid.guid();
  final tLocationId = faker.guid.guid();

  group('LocationsRemoteDataSourceImpl', () {
    group('Locations', () {
      test('should return SuccessState<List<LocationResponseModel>> on 200',
          () async {
        // Arrange
        final fakeResponse = {
          'data': [tLocationModel.toJson()],
          'message': 'Success',
        };

        when(() => mockHttpClient.get<dynamic>(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.locations),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.getLocations(tCompanyId);

        // Assert
        expect(result, isA<SuccessState<List<LocationResponseModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tLocationModel.id);
        verify(() => mockHttpClient.get<dynamic>(
              ApiEndpoints.locations,
              queryParameters: {'company_id': tCompanyId},
            )).called(1);
      });

      test('should return SuccessState<LocationResponseModel> on create',
          () async {
        // Arrange
        final fakeResponse = {
          'data': tLocationModel.toJson(),
          'message': 'Success',
        };

        when(() => mockHttpClient.post<dynamic>(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.locations),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.createLocation(tLocationRequest);

        // Assert
        expect(result, isA<SuccessState<LocationResponseModel>>());
        expect(result.data!.id, tLocationModel.id);
      });

      test('should return SuccessState<LocationResponseModel> on update',
          () async {
        // Arrange
        final fakeResponse = {
          'data': tLocationModel.toJson(),
          'message': 'Success',
        };

        when(() => mockHttpClient.put<dynamic>(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
                path: ApiEndpoints.locationById(tLocationRequest.id)),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.updateLocation(tLocationRequest);

        // Assert
        expect(result, isA<SuccessState<LocationResponseModel>>());
        expect(result.data!.id, tLocationModel.id);
      });

      test('should return SuccessState<void> on delete', () async {
        // Arrange
        final fakeResponse = {
          'message': 'Deleted',
        };

        when(() => mockHttpClient.delete<dynamic>(
              any(),
            )).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(
                path: ApiEndpoints.locationById(tLocationModel.id)),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.deleteLocation(tLocationModel.id);

        // Assert
        expect(result, isA<SuccessState<void>>());
      });
    });

    group('Areas', () {
      test('should return SuccessState<List<AreaResponseModel>> on 200',
          () async {
        // Arrange
        final fakeResponse = {
          'data': [tAreaModel.toJson()],
          'message': 'Success',
        };

        when(() => mockHttpClient.get<dynamic>(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.areas),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.getAreasByLocation(tLocationId);

        // Assert
        expect(result, isA<SuccessState<List<AreaResponseModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tAreaModel.id);
        verify(() => mockHttpClient.get<dynamic>(
              ApiEndpoints.areas,
              queryParameters: {'location_id': tLocationId},
            )).called(1);
      });

      test('should return SuccessState<AreaResponseModel> on create', () async {
        // Arrange
        final fakeResponse = {
          'data': tAreaModel.toJson(),
          'message': 'Success',
        };

        when(() => mockHttpClient.post<dynamic>(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.areas),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.createArea(tAreaRequest);

        // Assert
        expect(result, isA<SuccessState<AreaResponseModel>>());
        expect(result.data!.id, tAreaModel.id);
      });

      test('should return SuccessState<AreaResponseModel> on update', () async {
        // Arrange
        final fakeResponse = {
          'data': tAreaModel.toJson(),
          'message': 'Success',
        };

        when(() => mockHttpClient.put<dynamic>(
              any(),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            requestOptions:
                RequestOptions(path: ApiEndpoints.areaById(tAreaRequest.id)),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.updateArea(tAreaRequest);

        // Assert
        expect(result, isA<SuccessState<AreaResponseModel>>());
        expect(result.data!.id, tAreaModel.id);
      });

      test('should return SuccessState<void> on delete', () async {
        // Arrange
        final fakeResponse = {
          'message': 'Deleted',
        };

        when(() => mockHttpClient.delete<dynamic>(
              any(),
            )).thenAnswer(
          (_) async => Response(
            requestOptions:
                RequestOptions(path: ApiEndpoints.areaById(tAreaModel.id)),
            data: fakeResponse,
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.deleteArea(tAreaModel.id);

        // Assert
        expect(result, isA<SuccessState<void>>());
      });
    });
  });
}
