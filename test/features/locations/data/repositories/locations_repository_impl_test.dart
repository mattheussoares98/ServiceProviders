import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/requests/area_request_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/area_model.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/locations/data/repositories/locations_repository_impl.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';

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
    registerFallbackValue(
      AreaRequestModel.fromEntity(EntityFactory.makeAreaEntity()),
    );
    registerFallbackValue(<LocationModel>[]);
    registerFallbackValue(<AreaModel>[]);
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

  group('LocationsRepositoryImpl', () {
    group('getProviderLocations', () {
      test('should fetch from remote without caching when online', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getLocations(any()),
        ).thenAnswer((_) async => SuccessState(data: [tLocationModel]));

        final result = await repository.getProviderLocations(tCompanyId);

        expect(result, isA<SuccessState<List<LocationEntity>>>());
        expect(result.data!.first, equals(tLocationEntity));
        verify(() => mockRemoteDataSource.getLocations(tCompanyId)).called(1);
        verifyNever(() => mockLocalDataSource.saveLocations(any()));
      });

      test('should return failure offline, with no local fallback', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);

        final result = await repository.getProviderLocations(tCompanyId);

        expect(result, isA<FailureState<List<LocationEntity>>>());
        verifyNever(() => mockLocalDataSource.getLocations(any()));
      });
    });

    group('getProviderAreas', () {
      test('should fetch from remote without caching when online', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getAreas(any()),
        ).thenAnswer((_) async => SuccessState(data: [tAreaModel]));

        final result = await repository.getProviderAreas(tCompanyId);

        expect(result, isA<SuccessState<List<AreaEntity>>>());
        expect(result.data!.first, equals(tAreaEntity));
        verify(() => mockRemoteDataSource.getAreas(tCompanyId)).called(1);
        verifyNever(() => mockLocalDataSource.saveAreas(any()));
      });

      test('should return failure offline, with no local fallback', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);

        final result = await repository.getProviderAreas(tCompanyId);

        expect(result, isA<FailureState<List<AreaEntity>>>());
        verifyNever(() => mockLocalDataSource.getAreas(any()));
      });
    });

    group('getLocationsByIds', () {
      test('should fetch from remote without caching when online', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getLocationsByIds(any()),
        ).thenAnswer((_) async => SuccessState(data: [tLocationModel]));

        final result = await repository.getLocationsByIds([tLocationEntity.id]);

        expect(result, isA<SuccessState<List<LocationEntity>>>());
        expect(result.data!.first, equals(tLocationEntity));
        verify(
          () => mockRemoteDataSource.getLocationsByIds([tLocationEntity.id]),
        ).called(1);
        verifyNever(() => mockLocalDataSource.saveLocations(any()));
      });

      test('should return failure when remote fails', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getLocationsByIds(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.getLocationsByIds([tLocationEntity.id]);

        expect(result, isA<FailureState<List<LocationEntity>>>());
      });

      test('should return failure offline, with no local fallback', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);

        final result = await repository.getLocationsByIds([tLocationEntity.id]);

        expect(result, isA<FailureState<List<LocationEntity>>>());
        verifyNever(() => mockRemoteDataSource.getLocationsByIds(any()));
        verifyNever(() => mockLocalDataSource.getLocations(any()));
      });
    });

    group('getAreasByIds', () {
      test('should fetch from remote without caching when online', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getAreasByIds(any()),
        ).thenAnswer((_) async => SuccessState(data: [tAreaModel]));

        final result = await repository.getAreasByIds([tAreaEntity.id]);

        expect(result, isA<SuccessState<List<AreaEntity>>>());
        expect(result.data!.first, equals(tAreaEntity));
        verify(
          () => mockRemoteDataSource.getAreasByIds([tAreaEntity.id]),
        ).called(1);
        verifyNever(() => mockLocalDataSource.saveAreas(any()));
      });

      test('should return failure offline, with no local fallback', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);

        final result = await repository.getAreasByIds([tAreaEntity.id]);

        expect(result, isA<FailureState<List<AreaEntity>>>());
        verifyNever(() => mockRemoteDataSource.getAreasByIds(any()));
        verifyNever(() => mockLocalDataSource.getAreas(any()));
      });
    });

    group('getLocations', () {
      test(
        'should fetch locations from remote, cache them locally, and return list on success when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getLocations(any()),
          ).thenAnswer((_) async => SuccessState(data: [tLocationModel]));
          when(
            () => mockLocalDataSource.saveLocations(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.getLocations(tCompanyId);

          expect(result, isA<SuccessState<List<LocationEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tLocationEntity));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getLocations(tCompanyId)).called(1);
          verify(
            () => mockLocalDataSource.saveLocations([tLocationModel]),
          ).called(1);
          verifyNever(() => mockLocalDataSource.getLocations(any()));
        },
      );

      test(
        'should return failure when remote fetch succeeds but local cache fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getLocations(any()),
          ).thenAnswer((_) async => SuccessState(data: [tLocationModel]));
          when(
            () => mockLocalDataSource.saveLocations(any()),
          ).thenAnswer((_) async => FailureState(message: 'Cache error'));

          final result = await repository.getLocations(tCompanyId);

          expect(result, isA<FailureState<List<LocationEntity>>>());
          expect(result.message, 'Cache error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getLocations(tCompanyId)).called(1);
          verify(
            () => mockLocalDataSource.saveLocations([tLocationModel]),
          ).called(1);
        },
      );

      test(
        'should return failure when remote fetch fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getLocations(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

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
          when(
            () => mockLocalDataSource.getLocations(any()),
          ).thenAnswer((_) async => SuccessState(data: [tLocationModel]));

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
          when(
            () => mockLocalDataSource.getLocations(any()),
          ).thenAnswer((_) async => FailureState(message: 'Database error'));

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
        'should save location locally and return true when offline',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createLocation(tLocationEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockLocalDataSource.saveLocation(tLocationModel),
          ).called(1);
          verifyNever(() => mockRemoteDataSource.createLocation(any()));
        },
      );

      test(
        'should create location remotely, save locally, and return true when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createLocation(any()),
          ).thenAnswer((_) async => SuccessState(data: tLocationModel));
          when(
            () => mockLocalDataSource.saveLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createLocation(tLocationEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.createLocation(any())).called(1);
          verify(
            () => mockLocalDataSource.saveLocation(tLocationModel),
          ).called(1);
        },
      );

      test(
        'should return FailureState when remote creation fails when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createLocation(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          // Act
          final result = await repository.createLocation(tLocationEntity);

          // Assert
          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.createLocation(any())).called(1);
          verifyNever(() => mockLocalDataSource.saveLocation(any()));
        },
      );
    });

    group('updateLocation', () {
      test(
        'should save location locally and return true when offline',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.updateLocation(tLocationEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockLocalDataSource.saveLocation(tLocationModel),
          ).called(1);
          verifyNever(() => mockRemoteDataSource.updateLocation(any()));
        },
      );

      test(
        'should update location remotely, save locally, and return true when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateLocation(any()),
          ).thenAnswer((_) async => SuccessState(data: tLocationModel));
          when(
            () => mockLocalDataSource.saveLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.updateLocation(tLocationEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.updateLocation(any())).called(1);
          verify(
            () => mockLocalDataSource.saveLocation(tLocationModel),
          ).called(1);
        },
      );

      test(
        'should return FailureState when remote update fails when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateLocation(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          // Act
          final result = await repository.updateLocation(tLocationEntity);

          // Assert
          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.updateLocation(any())).called(1);
          verifyNever(() => mockLocalDataSource.saveLocation(any()));
        },
      );
    });

    group('deleteLocation', () {
      test(
        'should delete location locally and return true when offline',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.deleteLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.deleteLocation(tLocationEntity.id);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockLocalDataSource.deleteLocation(tLocationEntity.id),
          ).called(1);
          verifyNever(() => mockRemoteDataSource.deleteLocation(any()));
        },
      );

      test(
        'should delete location remotely, delete locally, and return true when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteLocation(any()),
          ).thenAnswer((_) async => SuccessState.nil);
          when(
            () => mockLocalDataSource.deleteLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.deleteLocation(tLocationEntity.id);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.deleteLocation(tLocationEntity.id),
          ).called(1);
          verify(
            () => mockLocalDataSource.deleteLocation(tLocationEntity.id),
          ).called(1);
        },
      );

      test(
        'should return FailureState when remote deletion fails when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteLocation(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          // Act
          final result = await repository.deleteLocation(tLocationEntity.id);

          // Assert
          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.deleteLocation(tLocationEntity.id),
          ).called(1);
          verifyNever(() => mockLocalDataSource.deleteLocation(any()));
        },
      );
    });

    group('getAreas', () {
      test(
        'should fetch areas from remote, cache them locally, and return list on success when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getAreas(any()),
          ).thenAnswer((_) async => SuccessState(data: [tAreaModel]));
          when(
            () => mockLocalDataSource.saveAreas(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.getAreas(tCompanyId);

          // Assert
          expect(result, isA<SuccessState<List<AreaEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tAreaEntity));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getAreas(tCompanyId)).called(1);
          verify(() => mockLocalDataSource.saveAreas([tAreaModel])).called(1);
          verifyNever(() => mockLocalDataSource.getAreas(any()));
        },
      );

      test(
        'should return failure when remote fetch succeeds but local cache fails when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getAreas(any()),
          ).thenAnswer((_) async => SuccessState(data: [tAreaModel]));
          when(
            () => mockLocalDataSource.saveAreas(any()),
          ).thenAnswer((_) async => FailureState(message: 'Cache error'));

          // Act
          final result = await repository.getAreas(tCompanyId);

          // Assert
          expect(result, isA<FailureState<List<AreaEntity>>>());
          expect(result.message, 'Cache error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getAreas(tCompanyId)).called(1);
          verify(() => mockLocalDataSource.saveAreas([tAreaModel])).called(1);
        },
      );

      test(
        'should return failure when remote fetch fails when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getAreas(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          // Act
          final result = await repository.getAreas(tCompanyId);

          // Assert
          expect(result, isA<FailureState<List<AreaEntity>>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getAreas(tCompanyId)).called(1);
          verifyNever(() => mockLocalDataSource.saveAreas(any()));
        },
      );

      test(
        'should return list of AreaEntity from local when offline',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.getAreas(any()),
          ).thenAnswer((_) async => SuccessState(data: [tAreaModel]));

          // Act
          final result = await repository.getAreas(tCompanyId);

          // Assert
          expect(result, isA<SuccessState<List<AreaEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tAreaEntity));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.getAreas(tCompanyId)).called(1);
          verifyNever(() => mockRemoteDataSource.getAreas(any()));
          verifyNever(() => mockLocalDataSource.saveAreas(any()));
        },
      );

      test(
        'should return failure when local fetch fails when offline',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.getAreas(any()),
          ).thenAnswer((_) async => FailureState(message: 'Database error'));

          // Act
          final result = await repository.getAreas(tCompanyId);

          // Assert
          expect(result, isA<FailureState<List<AreaEntity>>>());
          expect(result.message, 'Database error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.getAreas(tCompanyId)).called(1);
          verifyNever(() => mockRemoteDataSource.getAreas(any()));
        },
      );
    });

    group('createArea', () {
      test('should save area locally and return true when offline', () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveArea(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.createArea(tAreaEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockInternetClient.isConnected).called(1);
        verify(() => mockLocalDataSource.saveArea(tAreaModel)).called(1);
        verifyNever(() => mockRemoteDataSource.createArea(any()));
      });

      test(
        'should create area remotely, save locally, and return true when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createArea(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreaModel));
          when(
            () => mockLocalDataSource.saveArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createArea(tAreaEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.createArea(any())).called(1);
          verify(() => mockLocalDataSource.saveArea(tAreaModel)).called(1);
        },
      );

      test(
        'should return FailureState when remote creation fails when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createArea(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          // Act
          final result = await repository.createArea(tAreaEntity);

          // Assert
          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.createArea(any())).called(1);
          verifyNever(() => mockLocalDataSource.saveArea(any()));
        },
      );
    });

    group('updateArea', () {
      test('should save area locally and return true when offline', () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveArea(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.updateArea(tAreaEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockInternetClient.isConnected).called(1);
        verify(() => mockLocalDataSource.saveArea(tAreaModel)).called(1);
        verifyNever(() => mockRemoteDataSource.updateArea(any()));
      });

      test(
        'should update area remotely, save locally, and return true when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateArea(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreaModel));
          when(
            () => mockLocalDataSource.saveArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.updateArea(tAreaEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.updateArea(any())).called(1);
          verify(() => mockLocalDataSource.saveArea(tAreaModel)).called(1);
        },
      );

      test(
        'should return FailureState when remote update fails when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateArea(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          // Act
          final result = await repository.updateArea(tAreaEntity);

          // Assert
          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.updateArea(any())).called(1);
          verifyNever(() => mockLocalDataSource.saveArea(any()));
        },
      );
    });

    group('deleteArea', () {
      test('should delete area locally and return true when offline', () async {
        // Arrange
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.deleteArea(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.deleteArea(tAreaEntity.id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockInternetClient.isConnected).called(1);
        verify(() => mockLocalDataSource.deleteArea(tAreaEntity.id)).called(1);
        verifyNever(() => mockRemoteDataSource.deleteArea(any()));
      });

      test(
        'should delete area remotely, delete locally, and return true when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteArea(any()),
          ).thenAnswer((_) async => SuccessState.nil);
          when(
            () => mockLocalDataSource.deleteArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.deleteArea(tAreaEntity.id);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.deleteArea(tAreaEntity.id),
          ).called(1);
          verify(
            () => mockLocalDataSource.deleteArea(tAreaEntity.id),
          ).called(1);
        },
      );

      test(
        'should return FailureState when remote deletion fails when online',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteArea(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          // Act
          final result = await repository.deleteArea(tAreaEntity.id);

          // Assert
          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.deleteArea(tAreaEntity.id),
          ).called(1);
          verifyNever(() => mockLocalDataSource.deleteArea(any()));
        },
      );
    });

    group('Realtime', () {
      test(
        'watchLocationsRealtime caches insert/update in local and emits event',
        () async {
          final event = RealtimeEvent<LocationModel>(
            eventType: RealtimeEventType.insert,
            id: tLocationModel.id,
            companyId: tCompanyId,
            entity: tLocationModel,
          );

          when(
            () => mockRemoteDataSource.watchLocationsRealtime(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => Stream.value(event));
          when(
            () => mockLocalDataSource.saveLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final stream = repository.watchLocationsRealtime(companyId: tCompanyId);

          expect(
            stream,
            emits(
              predicate<RealtimeEvent<LocationEntity>>((e) {
                return e.eventType == RealtimeEventType.insert &&
                    e.id == tLocationModel.id &&
                    e.entity?.name == tLocationModel.name;
              }),
            ),
          );

          await pumpEventQueue();
          verify(() => mockLocalDataSource.saveLocation(tLocationModel)).called(1);
        },
      );

      test(
        'watchLocationsRealtime deletes from local and emits event on delete',
        () async {
          final event = RealtimeEvent<LocationModel>(
            eventType: RealtimeEventType.delete,
            id: tLocationModel.id,
            companyId: tCompanyId,
            entity: null,
          );

          when(
            () => mockRemoteDataSource.watchLocationsRealtime(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => Stream.value(event));
          when(
            () => mockLocalDataSource.deleteLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final stream = repository.watchLocationsRealtime(companyId: tCompanyId);

          expect(
            stream,
            emits(
              predicate<RealtimeEvent<LocationEntity>>((e) {
                return e.eventType == RealtimeEventType.delete &&
                    e.id == tLocationModel.id &&
                    e.entity == null;
              }),
            ),
          );

          await pumpEventQueue();
          verify(() => mockLocalDataSource.deleteLocation(tLocationModel.id)).called(1);
        },
      );

      test(
        'watchAreasRealtime caches insert/update in local and emits event',
        () async {
          final event = RealtimeEvent<AreaModel>(
            eventType: RealtimeEventType.update,
            id: tAreaModel.id,
            companyId: tCompanyId,
            entity: tAreaModel,
          );

          when(
            () => mockRemoteDataSource.watchAreasRealtime(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => Stream.value(event));
          when(
            () => mockLocalDataSource.saveArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final stream = repository.watchAreasRealtime(companyId: tCompanyId);

          expect(
            stream,
            emits(
              predicate<RealtimeEvent<AreaEntity>>((e) {
                return e.eventType == RealtimeEventType.update &&
                    e.id == tAreaModel.id &&
                    e.entity?.name == tAreaModel.name;
              }),
            ),
          );

          await pumpEventQueue();
          verify(() => mockLocalDataSource.saveArea(tAreaModel)).called(1);
        },
      );

      test(
        'watchAreasRealtime deletes from local and emits event on delete',
        () async {
          final event = RealtimeEvent<AreaModel>(
            eventType: RealtimeEventType.delete,
            id: tAreaModel.id,
            companyId: tCompanyId,
            entity: null,
          );

          when(
            () => mockRemoteDataSource.watchAreasRealtime(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => Stream.value(event));
          when(
            () => mockLocalDataSource.deleteArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final stream = repository.watchAreasRealtime(companyId: tCompanyId);

          expect(
            stream,
            emits(
              predicate<RealtimeEvent<AreaEntity>>((e) {
                return e.eventType == RealtimeEventType.delete &&
                    e.id == tAreaModel.id &&
                    e.entity == null;
              }),
            ),
          );

          await pumpEventQueue();
          verify(() => mockLocalDataSource.deleteArea(tAreaModel.id)).called(1);
        },
      );
    });
  });
}
