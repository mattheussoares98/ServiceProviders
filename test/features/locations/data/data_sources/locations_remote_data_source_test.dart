import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:clean_architecture/features/locations/data/models/requests/area_request_model.dart';
import 'package:clean_architecture/features/locations/data/models/requests/location_request_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/area_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/location_model.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockSupabaseDatabaseClient;
  late LocationsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockSupabaseDatabaseClient = MockSupabaseDatabaseClient();
    dataSource = LocationsRemoteDataSourceImpl(
      database: mockSupabaseDatabaseClient,
    );
  });

  final tLocationEntity = EntityFactory.makeLocationEntity();
  final tLocationModel = LocationModel.fromEntity(tLocationEntity);
  final tLocationRequest = LocationRequestModel.fromEntity(tLocationEntity);

  final tAreaEntity = EntityFactory.makeAreaEntity();
  final tAreaModel = AreaModel.fromEntity(tAreaEntity);
  final tAreaRequest = AreaRequestModel.fromEntity(tAreaEntity);

  final tCompanyId = faker.guid.guid();
  final tLocationId = faker.guid.guid();

  group('LocationsRemoteDataSourceImpl', () {
    group('Locations', () {
      test('should return SuccessState<List<LocationModel>> on 200', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tLocationModel.toJson()]);

        // Act
        final result = await dataSource.getLocations(tCompanyId);

        // Assert
        expect(result, isA<SuccessState<List<LocationModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tLocationModel.id);
        verify(
          () => mockSupabaseDatabaseClient.selectList(
            table: 'locations',
            filters: [SupabaseFilter.eq('company_id', tCompanyId)],
          ),
        ).called(1);
      });

      test('should return SuccessState<LocationModel> on create', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tLocationModel.toJson()]);

        // Act
        final result = await dataSource.createLocation(tLocationRequest);

        // Assert
        expect(result, isA<SuccessState<LocationModel>>());
        expect(result.data!.id, tLocationModel.id);
        verify(
          () => mockSupabaseDatabaseClient.insert(
            table: 'locations',
            values: tLocationRequest.toJson(),
          ),
        ).called(1);
      });

      test('should return SuccessState<LocationModel> on update', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tLocationModel.toJson()]);

        // Act
        final result = await dataSource.updateLocation(tLocationRequest);

        // Assert
        expect(result, isA<SuccessState<LocationModel>>());
        expect(result.data!.id, tLocationModel.id);
        verify(
          () => mockSupabaseDatabaseClient.update(
            table: 'locations',
            values: tLocationRequest.toJson(),
            filters: [SupabaseFilter.eq('id', tLocationRequest.id)],
          ),
        ).called(1);
      });

      test('should return SuccessState<void> on delete', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.delete(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.deleteLocation(tLocationModel.id);

        // Assert
        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockSupabaseDatabaseClient.delete(
            table: 'locations',
            filters: [SupabaseFilter.eq('id', tLocationModel.id)],
          ),
        ).called(1);
      });
    });

    group('Areas', () {
      test('should return SuccessState<List<AreaModel>> on 200', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tAreaModel.toJson()]);

        // Act
        final result = await dataSource.getAreasByLocation(tLocationId);

        // Assert
        expect(result, isA<SuccessState<List<AreaModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tAreaModel.id);
        verify(
          () => mockSupabaseDatabaseClient.selectList(
            table: 'areas',
            filters: [SupabaseFilter.eq('location_id', tLocationId)],
          ),
        ).called(1);
      });

      test('should return SuccessState<AreaModel> on create', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tAreaModel.toJson()]);

        // Act
        final result = await dataSource.createArea(tAreaRequest);

        // Assert
        expect(result, isA<SuccessState<AreaModel>>());
        expect(result.data!.id, tAreaModel.id);
        verify(
          () => mockSupabaseDatabaseClient.insert(
            table: 'areas',
            values: tAreaRequest.toJson(),
          ),
        ).called(1);
      });

      test('should return SuccessState<AreaModel> on update', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tAreaModel.toJson()]);

        // Act
        final result = await dataSource.updateArea(tAreaRequest);

        // Assert
        expect(result, isA<SuccessState<AreaModel>>());
        expect(result.data!.id, tAreaModel.id);
        verify(
          () => mockSupabaseDatabaseClient.update(
            table: 'areas',
            values: tAreaRequest.toJson(),
            filters: [SupabaseFilter.eq('id', tAreaRequest.id)],
          ),
        ).called(1);
      });

      test('should return SuccessState<void> on delete', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.delete(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => []);

        // Act {
        final result = await dataSource.deleteArea(tAreaModel.id);

        // Assert
        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockSupabaseDatabaseClient.delete(
            table: 'areas',
            filters: [SupabaseFilter.eq('id', tAreaModel.id)],
          ),
        ).called(1);
      });
    });
  });
}
