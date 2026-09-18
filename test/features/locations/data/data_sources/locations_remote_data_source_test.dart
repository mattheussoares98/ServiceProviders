import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/requests/area_request_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/address_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/asset_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockSupabaseDatabaseClient;
  late MockSupabaseRealtimeClient mockSupabaseRealtimeClient;
  late MockHttpClient mockHttpClient;
  late LocationsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockSupabaseDatabaseClient = MockSupabaseDatabaseClient();
    mockSupabaseRealtimeClient = MockSupabaseRealtimeClient();
    mockHttpClient = MockHttpClient();
    dataSource = LocationsRemoteDataSourceImpl(
      database: mockSupabaseDatabaseClient,
      realtimeClient: mockSupabaseRealtimeClient,
      httpClient: mockHttpClient,
    );
  });

  final tLocationEntity = AssetFactory.makeLocationEntity();
  final tLocationModel = LocationModel.fromEntity(tLocationEntity);
  final tLocationRequest = LocationModel.fromEntity(tLocationEntity);

  final tAreaEntity = AssetFactory.makeAreaEntity();
  final tAreaModel = AreaModel.fromEntity(tAreaEntity);
  final tAreaRequest = AreaRequestModel.fromEntity(tAreaEntity);

  final tCompanyId = faker.guid.guid();

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
            filters: [
              SupabaseFilter.eq('company_id', tCompanyId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      });

      test('should fetch locations by id for provider mode', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tLocationModel.toJson()]);

        // Act
        final result = await dataSource.getLocationsByIds([tLocationModel.id]);

        // Assert
        expect(result, isA<SuccessState<List<LocationModel>>>());
        expect(result.data!.first.id, tLocationModel.id);
        verify(
          () => mockSupabaseDatabaseClient.selectList(
            table: 'locations',
            filters: [
              SupabaseFilter.inList('id', [tLocationModel.id]),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      });

      test('should not query when the location id list is empty', () async {
        // Act
        final result = await dataSource.getLocationsByIds([]);

        // Assert
        expect(result, isA<SuccessState<List<LocationModel>>>());
        expect(result.data, isEmpty);
        verifyNever(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        );
      });

      test('should return FailureState when the by-id query throws', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception(faker.lorem.sentence()));

        // Act
        final result = await dataSource.getLocationsByIds([tLocationModel.id]);

        // Assert
        expect(result, isA<FailureState<List<LocationModel>>>());
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
          () => mockSupabaseDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tLocationModel.toJson()]);

        // Act
        final result = await dataSource.deleteLocation(tLocationModel.id);

        // Assert
        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockSupabaseDatabaseClient.update(
            table: 'locations',
            values: any(named: 'values'),
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
        final result = await dataSource.getAreas(tCompanyId);

        // Assert
        expect(result, isA<SuccessState<List<AreaModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first.id, tAreaModel.id);
        verify(
          () => mockSupabaseDatabaseClient.selectList(
            table: 'areas',
            filters: [
              SupabaseFilter.eq('company_id', tCompanyId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      });

      test('should fetch areas by id for provider mode', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tAreaModel.toJson()]);

        // Act
        final result = await dataSource.getAreasByIds([tAreaModel.id]);

        // Assert
        expect(result, isA<SuccessState<List<AreaModel>>>());
        expect(result.data!.first.id, tAreaModel.id);
        verify(
          () => mockSupabaseDatabaseClient.selectList(
            table: 'areas',
            filters: [
              SupabaseFilter.inList('id', [tAreaModel.id]),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      });

      test('should not query when the area id list is empty', () async {
        // Act
        final result = await dataSource.getAreasByIds([]);

        // Assert
        expect(result, isA<SuccessState<List<AreaModel>>>());
        expect(result.data, isEmpty);
        verifyNever(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        );
      });

      test('should return FailureState when the by-id query throws', () async {
        // Arrange
        when(
          () => mockSupabaseDatabaseClient.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception(faker.lorem.sentence()));

        // Act
        final result = await dataSource.getAreasByIds([tAreaModel.id]);

        // Assert
        expect(result, isA<FailureState<List<AreaModel>>>());
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
          () => mockSupabaseDatabaseClient.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tAreaModel.toJson()]);

        // Act
        final result = await dataSource.deleteArea(tAreaModel.id);

        // Assert
        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockSupabaseDatabaseClient.update(
            table: 'areas',
            values: any(named: 'values'),
            filters: [SupabaseFilter.eq('id', tAreaModel.id)],
          ),
        ).called(1);
      });
    });

    group('Realtime', () {
      test('watchLocationsRealtime streams realtime events', () {
        final payload = PostgresChangePayload(
          eventType: PostgresChangeEvent.insert,
          newRecord: tLocationModel.toJson(),
          oldRecord: {},
          schema: 'public',
          table: 'locations',
          errors: <dynamic>[],
          commitTimestamp: DateTime.now(),
        );

        when(
          () => mockSupabaseRealtimeClient.streamTableChanges(
            table: 'locations',
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) => Stream.value(payload));

        final stream = dataSource.watchLocationsRealtime(companyId: tCompanyId);

        expect(
          stream,
          emits(
            predicate<RealtimeEvent<LocationModel>>((event) {
              return event.eventType == RealtimeEventType.insert &&
                  event.id == tLocationModel.id &&
                  event.entity?.name == tLocationModel.name;
            }),
          ),
        );
      });

      test('watchAreasRealtime streams realtime events', () {
        final payload = PostgresChangePayload(
          eventType: PostgresChangeEvent.update,
          newRecord: tAreaModel.toJson(),
          oldRecord: {'id': tAreaModel.id},
          schema: 'public',
          table: 'areas',
          errors: <dynamic>[],
          commitTimestamp: DateTime.now(),
        );

        when(
          () => mockSupabaseRealtimeClient.streamTableChanges(
            table: 'areas',
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) => Stream.value(payload));

        final stream = dataSource.watchAreasRealtime(companyId: tCompanyId);

        expect(
          stream,
          emits(
            predicate<RealtimeEvent<AreaModel>>((event) {
              return event.eventType == RealtimeEventType.update &&
                  event.id == tAreaModel.id &&
                  event.entity?.name == tAreaModel.name;
            }),
          ),
        );
      });
    });

    group('getAddressByCep', () {
      final tAddress = AssetFactory.makeAddressEntity();
      // final tAddressModel = AddressModel.fromEntity(tAddress);
      const tCep = '01001-000';
      const tCleanCep = '01001000';

      test(
        'should return SuccessState<AddressModel> when ViaCEP returns address',
        () async {
          when(() => mockHttpClient.get<dynamic>(any())).thenAnswer(
            (_) async => Response(
              data: {
                'cep': '01001-000',
                'logradouro': tAddress.street,
                'complemento': tAddress.complement,
                'bairro': tAddress.neighborhood,
                'localidade': tAddress.city,
                'uf': tAddress.state,
              },
              statusCode: 200,
              requestOptions: RequestOptions(
                path: 'https://viacep.com.br/ws/$tCleanCep/json/',
              ),
            ),
          );

          final result = await dataSource.getAddressByCep(tCep);

          expect(result, isA<SuccessState<AddressModel>>());
          expect(result.data?.street, tAddress.street);
          expect(result.data?.city, tAddress.city);
          verify(
            () => mockHttpClient.get<dynamic>(
              'https://viacep.com.br/ws/$tCleanCep/json/',
            ),
          ).called(1);
        },
      );

      test('should return FailureState when ViaCEP returns erro', () async {
        when(() => mockHttpClient.get<dynamic>(any())).thenAnswer(
          (_) async => Response(
            data: {'erro': 'true'},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: 'https://viacep.com.br/ws/$tCleanCep/json/',
            ),
          ),
        );

        final result = await dataSource.getAddressByCep(tCep);

        expect(result, isA<FailureState<AddressModel>>());
      });

      test('should return FailureState on Dio exception', () async {
        when(() => mockHttpClient.get<dynamic>(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(
              path: 'https://viacep.com.br/ws/$tCleanCep/json/',
            ),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        final result = await dataSource.getAddressByCep(tCep);

        expect(result, isA<FailureState<AddressModel>>());
      });
    });
  });
}
