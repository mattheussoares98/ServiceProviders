import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/locations/data/models/responses/area_model.dart';
import 'package:clean_architecture/features/locations/data/models/responses/location_model.dart';
import 'package:clean_architecture/features/locations/data/repositories/locations_repository_impl.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockLocationsRemoteDataSource mockRemoteDataSource;
  late MockLocationsLocalDataSource mockLocalDataSource;
  late LocationsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      LocationModel.fromEntity(EntityFactory.makeLocationEntity()),
    );
    registerFallbackValue(AreaModel.fromEntity(EntityFactory.makeAreaEntity()));
    registerFallbackValue(<LocationModel>[]);
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockLocationsRemoteDataSource();
    mockLocalDataSource = MockLocationsLocalDataSource();
    repository = LocationsRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tLocationEntity = EntityFactory.makeLocationEntity();
  final tLocationModel = LocationModel.fromEntity(tLocationEntity);
  final tAreaEntity = EntityFactory.makeAreaEntity();
  final tAreaModel = AreaModel.fromEntity(tAreaEntity);
  final tCompanyId = faker.guid.guid();
  final tLocationId = faker.guid.guid();

  group('LocationsRepositoryImpl', () {
    group('getLocations', () {
      test(
        'should fetch locations from remote, cache them locally, and return list on success when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(() => mockRemoteDataSource.getLocations(any()))
              .thenAnswer((_) async => SuccessState(data: [tLocationModel]));
          when(() => mockLocalDataSource.saveLocations(any()))
              .thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.getLocations(tCompanyId);

          expect(result, isA<SuccessState<List<LocationEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tLocationEntity));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getLocations(tCompanyId)).called(1);
          verify(() => mockLocalDataSource.saveLocations([tLocationModel])).called(1);
          verifyNever(() => mockLocalDataSource.getLocations(any()));
        },
      );

      test(
        'should return failure when remote fetch succeeds but local cache fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(() => mockRemoteDataSource.getLocations(any()))
              .thenAnswer((_) async => SuccessState(data: [tLocationModel]));
          when(() => mockLocalDataSource.saveLocations(any()))
              .thenAnswer((_) async => FailureState(message: 'Cache error'));

          final result = await repository.getLocations(tCompanyId);

          expect(result, isA<FailureState<List<LocationEntity>>>());
          expect(result.message, 'Cache error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getLocations(tCompanyId)).called(1);
          verify(() => mockLocalDataSource.saveLocations([tLocationModel])).called(1);
        },
      );

      test(
        'should return failure when remote fetch fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(() => mockRemoteDataSource.getLocations(any()))
              .thenAnswer((_) async => FailureState(message: 'Server error'));

          final result = await repository.getLocations(tCompanyId);

          expect(result, isA<FailureState<List<LocationEntity>>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getLocations(tCompanyId)).called(1);
          verifyNever(() => mockLocalDataSource.saveLocations(any()));
        },
      );

      test(
        'should return list of LocationEntity from local when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(() => mockLocalDataSource.getLocations(any()))
              .thenAnswer((_) async => SuccessState(data: [tLocationModel]));

          final result = await repository.getLocations(tCompanyId);

          expect(result, isA<SuccessState<List<LocationEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tLocationEntity));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.getLocations(tCompanyId)).called(1);
          verifyNever(() => mockRemoteDataSource.getLocations(any()));
          verifyNever(() => mockLocalDataSource.saveLocations(any()));
        },
      );

      test(
        'should return failure when local fetch fails when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(() => mockLocalDataSource.getLocations(any()))
              .thenAnswer((_) async => FailureState(message: 'Database error'));

          final result = await repository.getLocations(tCompanyId);

          expect(result, isA<FailureState<List<LocationEntity>>>());
          expect(result.message, 'Database error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.getLocations(tCompanyId)).called(1);
          verifyNever(() => mockRemoteDataSource.getLocations(any()));
        },
      );
    });

    group('createLocation', () {
      test(
        'should return true when location is saved successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createLocation(tLocationEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.saveLocation(tLocationModel),
          ).called(1);
        },
      );
    });

    group('updateLocation', () {
      test(
        'should return true when location is updated successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.updateLocation(tLocationEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.saveLocation(tLocationModel),
          ).called(1);
        },
      );
    });

    group('deleteLocation', () {
      test(
        'should return true when location is deleted successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.deleteLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.deleteLocation(tLocationEntity.id);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.deleteLocation(tLocationEntity.id),
          ).called(1);
        },
      );
    });

    group('getAreasByLocation', () {
      test(
        'should return list of AreaEntity on success from local data source',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getAreasByLocation(any()),
          ).thenAnswer((_) async => SuccessState(data: [tAreaModel]));

          // Act
          final result = await repository.getAreasByLocation(tLocationId);

          // Assert
          expect(result, isA<SuccessState<List<AreaEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tAreaEntity));
          verify(
            () => mockLocalDataSource.getAreasByLocation(tLocationId),
          ).called(1);
        },
      );

      test('should return FailureState when local data source fails', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getAreasByLocation(any()),
        ).thenAnswer((_) async => FailureState(message: 'Database error'));

        // Act
        final result = await repository.getAreasByLocation(tLocationId);

        // Assert
        expect(result, isA<FailureState<List<AreaEntity>>>());
        expect(result.message, 'Database error');
      });
    });

    group('createArea', () {
      test(
        'should return true when area is saved successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createArea(tAreaEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveArea(tAreaModel)).called(1);
        },
      );
    });

    group('updateArea', () {
      test(
        'should return true when area is updated successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.updateArea(tAreaEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveArea(tAreaModel)).called(1);
        },
      );
    });

    group('deleteArea', () {
      test(
        'should return true when area is deleted successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.deleteArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.deleteArea(tAreaEntity.id);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.deleteArea(tAreaEntity.id),
          ).called(1);
        },
      );
    });
  });
}
