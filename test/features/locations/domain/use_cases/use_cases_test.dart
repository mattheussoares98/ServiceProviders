import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/create_area_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/create_location_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/delete_area_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/delete_location_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_areas_by_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_areas_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_locations_by_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_locations_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_provider_areas_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_provider_locations_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/update_area_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/update_location_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockLocationsRepository mockRepository;

  // Use cases
  late CreateLocationUseCase createLocationUseCase;
  late UpdateLocationUseCase updateLocationUseCase;
  late DeleteLocationUseCase deleteLocationUseCase;
  late GetLocationsUseCase getLocationsUseCase;
  late CreateAreaUseCase createAreaUseCase;
  late UpdateAreaUseCase updateAreaUseCase;
  late DeleteAreaUseCase deleteAreaUseCase;
  late GetAreasUseCase getAreasUseCase;
  late GetLocationsByIdsUseCase getLocationsByIdsUseCase;
  late GetAreasByIdsUseCase getAreasByIdsUseCase;
  late GetProviderLocationsUseCase getProviderLocationsUseCase;
  late GetProviderAreasUseCase getProviderAreasUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeLocationEntity());
    registerFallbackValue(EntityFactory.makeAreaEntity());
  });

  setUp(() {
    mockRepository = MockLocationsRepository();
    createLocationUseCase = CreateLocationUseCase(
      locationsRepository: mockRepository,
    );
    updateLocationUseCase = UpdateLocationUseCase(
      locationsRepository: mockRepository,
    );
    deleteLocationUseCase = DeleteLocationUseCase(
      locationsRepository: mockRepository,
    );
    getLocationsUseCase = GetLocationsUseCase(
      locationsRepository: mockRepository,
    );
    createAreaUseCase = CreateAreaUseCase(locationsRepository: mockRepository);
    updateAreaUseCase = UpdateAreaUseCase(locationsRepository: mockRepository);
    deleteAreaUseCase = DeleteAreaUseCase(locationsRepository: mockRepository);
    getAreasUseCase = GetAreasUseCase(locationsRepository: mockRepository);
    getLocationsByIdsUseCase = GetLocationsByIdsUseCase(
      locationsRepository: mockRepository,
    );
    getAreasByIdsUseCase = GetAreasByIdsUseCase(
      locationsRepository: mockRepository,
    );
    getProviderLocationsUseCase = GetProviderLocationsUseCase(
      locationsRepository: mockRepository,
    );
    getProviderAreasUseCase = GetProviderAreasUseCase(
      locationsRepository: mockRepository,
    );
  });

  final tLocationEntity = EntityFactory.makeLocationEntity();
  final tLocationList = EntityFactory.makeLocationEntityList();
  final tAreaEntity = EntityFactory.makeAreaEntity();
  final tAreaList = EntityFactory.makeAreaEntityList();
  final tId = faker.guid.guid();

  group('Locations & Areas Use Cases', () {
    group('CreateLocationUseCase', () {
      test(
        'should call repository.createLocation and return SuccessState',
        () async {
          // Arrange
          when(
            () => mockRepository.createLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await createLocationUseCase(tLocationEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRepository.createLocation(tLocationEntity),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.createLocation(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        // Act
        final result = await createLocationUseCase(tLocationEntity);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.createLocation(tLocationEntity)).called(1);
      });
    });

    group('UpdateLocationUseCase', () {
      test(
        'should call repository.updateLocation and return SuccessState',
        () async {
          // Arrange
          when(
            () => mockRepository.updateLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await updateLocationUseCase(tLocationEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRepository.updateLocation(tLocationEntity),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.updateLocation(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        // Act
        final result = await updateLocationUseCase(tLocationEntity);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.updateLocation(tLocationEntity)).called(1);
      });
    });

    group('DeleteLocationUseCase', () {
      test(
        'should call repository.deleteLocation and return SuccessState',
        () async {
          // Arrange
          when(
            () => mockRepository.deleteLocation(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await deleteLocationUseCase(tId);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.deleteLocation(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.deleteLocation(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        // Act
        final result = await deleteLocationUseCase(tId);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.deleteLocation(tId)).called(1);
      });
    });

    group('GetLocationsUseCase', () {
      test(
        'should call repository.getLocations and return list of locations',
        () async {
          // Arrange
          when(
            () => mockRepository.getLocations(any()),
          ).thenAnswer((_) async => SuccessState(data: tLocationList));

          // Act
          final result = await getLocationsUseCase(tId);

          // Assert
          expect(result, isA<SuccessState<List<LocationEntity>>>());
          expect(result.data, tLocationList);
          verify(() => mockRepository.getLocations(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getLocations(any())).thenAnswer(
          (_) async => FailureState<List<LocationEntity>>(message: 'Error'),
        );

        // Act
        final result = await getLocationsUseCase(tId);

        // Assert
        expect(result, isA<FailureState<List<LocationEntity>>>());
        verify(() => mockRepository.getLocations(tId)).called(1);
      });
    });

    group('CreateAreaUseCase', () {
      test(
        'should call repository.createArea and return SuccessState',
        () async {
          // Arrange
          when(
            () => mockRepository.createArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await createAreaUseCase(tAreaEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.createArea(tAreaEntity)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.createArea(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        // Act
        final result = await createAreaUseCase(tAreaEntity);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.createArea(tAreaEntity)).called(1);
      });
    });

    group('UpdateAreaUseCase', () {
      test(
        'should call repository.updateArea and return SuccessState',
        () async {
          // Arrange
          when(
            () => mockRepository.updateArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await updateAreaUseCase(tAreaEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.updateArea(tAreaEntity)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.updateArea(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        // Act
        final result = await updateAreaUseCase(tAreaEntity);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.updateArea(tAreaEntity)).called(1);
      });
    });

    group('DeleteAreaUseCase', () {
      test(
        'should call repository.deleteArea and return SuccessState',
        () async {
          // Arrange
          when(
            () => mockRepository.deleteArea(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await deleteAreaUseCase(tId);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.deleteArea(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.deleteArea(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        // Act
        final result = await deleteAreaUseCase(tId);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.deleteArea(tId)).called(1);
      });
    });

    group('GetProviderLocationsUseCase', () {
      test(
        'should call repository.getProviderLocations and return locations',
        () async {
          // Arrange
          when(
            () => mockRepository.getProviderLocations(any()),
          ).thenAnswer((_) async => SuccessState(data: tLocationList));

          // Act
          final result = await getProviderLocationsUseCase(tId);

          // Assert
          expect(result, isA<SuccessState<List<LocationEntity>>>());
          expect(result.data, tLocationList);
          verify(() => mockRepository.getProviderLocations(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getProviderLocations(any())).thenAnswer(
          (_) async => FailureState<List<LocationEntity>>(message: 'Error'),
        );

        // Act
        final result = await getProviderLocationsUseCase(tId);

        // Assert
        expect(result, isA<FailureState<List<LocationEntity>>>());
      });
    });

    group('GetProviderAreasUseCase', () {
      test(
        'should call repository.getProviderAreas and return areas',
        () async {
          // Arrange
          when(
            () => mockRepository.getProviderAreas(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreaList));

          // Act
          final result = await getProviderAreasUseCase(tId);

          // Assert
          expect(result, isA<SuccessState<List<AreaEntity>>>());
          expect(result.data, tAreaList);
          verify(() => mockRepository.getProviderAreas(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getProviderAreas(any())).thenAnswer(
          (_) async => FailureState<List<AreaEntity>>(message: 'Error'),
        );

        // Act
        final result = await getProviderAreasUseCase(tId);

        // Assert
        expect(result, isA<FailureState<List<AreaEntity>>>());
      });
    });

    group('GetLocationsByIdsUseCase', () {
      test(
        'should call repository.getLocationsByIds and return locations',
        () async {
          // Arrange
          when(
            () => mockRepository.getLocationsByIds(any()),
          ).thenAnswer((_) async => SuccessState(data: tLocationList));

          // Act
          final result = await getLocationsByIdsUseCase([tId]);

          // Assert
          expect(result, isA<SuccessState<List<LocationEntity>>>());
          expect(result.data, tLocationList);
          verify(() => mockRepository.getLocationsByIds([tId])).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getLocationsByIds(any())).thenAnswer(
          (_) async => FailureState<List<LocationEntity>>(message: 'Error'),
        );

        // Act
        final result = await getLocationsByIdsUseCase([tId]);

        // Assert
        expect(result, isA<FailureState<List<LocationEntity>>>());
        verify(() => mockRepository.getLocationsByIds([tId])).called(1);
      });
    });

    group('GetAreasByIdsUseCase', () {
      test('should call repository.getAreasByIds and return areas', () async {
        // Arrange
        when(
          () => mockRepository.getAreasByIds(any()),
        ).thenAnswer((_) async => SuccessState(data: tAreaList));

        // Act
        final result = await getAreasByIdsUseCase([tId]);

        // Assert
        expect(result, isA<SuccessState<List<AreaEntity>>>());
        expect(result.data, tAreaList);
        verify(() => mockRepository.getAreasByIds([tId])).called(1);
      });

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getAreasByIds(any())).thenAnswer(
          (_) async => FailureState<List<AreaEntity>>(message: 'Error'),
        );

        // Act
        final result = await getAreasByIdsUseCase([tId]);

        // Assert
        expect(result, isA<FailureState<List<AreaEntity>>>());
        verify(() => mockRepository.getAreasByIds([tId])).called(1);
      });
    });

    group('GetAreasUseCase', () {
      test(
        'should call repository.getAreas and return list of areas',
        () async {
          // Arrange
          when(
            () => mockRepository.getAreas(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreaList));

          // Act
          final result = await getAreasUseCase(tId);

          // Assert
          expect(result, isA<SuccessState<List<AreaEntity>>>());
          expect(result.data, tAreaList);
          verify(() => mockRepository.getAreas(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getAreas(any())).thenAnswer(
          (_) async => FailureState<List<AreaEntity>>(message: 'Error'),
        );

        // Act
        final result = await getAreasUseCase(tId);

        // Assert
        expect(result, isA<FailureState<List<AreaEntity>>>());
        verify(() => mockRepository.getAreas(tId)).called(1);
      });
    });
  });
}
