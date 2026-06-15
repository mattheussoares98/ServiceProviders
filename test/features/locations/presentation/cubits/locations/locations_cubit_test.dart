import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/create_area_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/create_location_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/delete_area_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/delete_location_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/get_areas_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/get_locations_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/update_area_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/update_location_use_case.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit_use_cases.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockGetLocationsUseCase extends Mock implements GetLocationsUseCase {}

class MockGetAreasUseCase extends Mock implements GetAreasUseCase {}

class MockCreateLocationUseCase extends Mock implements CreateLocationUseCase {}

class MockUpdateLocationUseCase extends Mock implements UpdateLocationUseCase {}

class MockDeleteLocationUseCase extends Mock implements DeleteLocationUseCase {}

class MockCreateAreaUseCase extends Mock implements CreateAreaUseCase {}

class MockUpdateAreaUseCase extends Mock implements UpdateAreaUseCase {}

class MockDeleteAreaUseCase extends Mock implements DeleteAreaUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetLocationsUseCase mockGetLocations;
  late MockGetAreasUseCase mockGetAreas;
  late MockCreateLocationUseCase mockCreateLocation;
  late MockUpdateLocationUseCase mockUpdateLocation;
  late MockDeleteLocationUseCase mockDeleteLocation;
  late MockCreateAreaUseCase mockCreateArea;
  late MockUpdateAreaUseCase mockUpdateArea;
  late MockDeleteAreaUseCase mockDeleteArea;
  late MockNavigationClient mockNavigationClient;

  late LocationsCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeLocationEntity());
    registerFallbackValue(EntityFactory.makeAreaEntity());
  });

  setUp(() {
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetLocations = MockGetLocationsUseCase();
    mockGetAreas = MockGetAreasUseCase();
    mockCreateLocation = MockCreateLocationUseCase();
    mockUpdateLocation = MockUpdateLocationUseCase();
    mockDeleteLocation = MockDeleteLocationUseCase();
    mockCreateArea = MockCreateAreaUseCase();
    mockUpdateArea = MockUpdateAreaUseCase();
    mockDeleteArea = MockDeleteAreaUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();

    when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);

    final useCases = LocationsCubitUseCases(
      getSessionUser: mockGetSessionUser,
      getLocations: mockGetLocations,
      getAreas: mockGetAreas,
      createLocation: mockCreateLocation,
      updateLocation: mockUpdateLocation,
      deleteLocation: mockDeleteLocation,
      createArea: mockCreateArea,
      updateArea: mockUpdateArea,
      deleteArea: mockDeleteArea,
    );

    cubit = LocationsCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('LocationsCubit Tests', () {
    group('loadLocations', () {
      blocTest<LocationsCubit, LocationsState>(
        'should emit loading and loaded when locations load successfully',
        build: () {
          final tLocations = EntityFactory.makeLocationEntityList();
          final tAreas = EntityFactory.makeAreaEntityList();
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tLocations));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreas));
          return cubit;
        },
        act: (cubit) => cubit.loadLocationsAndAreas(),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.locations, 'locations', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should emit loading and error when locations load fails',
        build: () {
          final tMessage = faker.lorem.sentence();
          when(() => mockGetLocations.call(any())).thenAnswer(
            (_) async => FailureState<List<LocationEntity>>(message: tMessage),
          );
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.loadLocationsAndAreas(),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>()
              .having((s) => s.status, 'status', StateStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should emit error when companyId is empty',
        build: () {
          final emptyUser = tUserProfile.copyWith(annulCompanyId: true);
          when(() => mockGetSessionUser.call()).thenReturn(emptyUser);
          return cubit;
        },
        act: (cubit) => cubit.loadLocationsAndAreas(),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verifyNever(() => mockGetLocations.call(any()));
        },
      );
    });

    group('loadAreas', () {
      blocTest<LocationsCubit, LocationsState>(
        'should emit updated areasByLocation map when areas load successfully',
        build: () {
          final tAreas = EntityFactory.makeAreaEntityList();
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreas));
          return cubit;
        },
        act: (cubit) => cubit.loadAreas(tUserProfile.companyId),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.areasByLocation,
            'areasByLocation',
            isNotEmpty,
          ),
        ],
        verify: (_) {
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should not emit state but show error when areas load fails',
        build: () {
          when(() => mockGetAreas.call(any())).thenAnswer(
            (_) async => FailureState<List<AreaEntity>>(message: 'Error'),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadAreas(tUserProfile.companyId),
        expect: () => <LocationsState>[],
        verify: (_) {
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );
    });

    group('createLocation', () {
      final tLocation = EntityFactory.makeLocationEntity();

      blocTest<LocationsCubit, LocationsState>(
        'should emit loading and load locations when creation succeeds',
        build: () {
          when(
            () => mockCreateLocation.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.createLocation(tLocation),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateLocation.call(tLocation)).called(1);
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should emit error when creation fails',
        build: () {
          when(
            () => mockCreateLocation.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) => cubit.createLocation(tLocation),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateLocation.call(tLocation)).called(1);
          verifyNever(() => mockGetLocations.call(any()));
        },
      );
    });

    group('updateLocation', () {
      final tLocation = EntityFactory.makeLocationEntity();

      blocTest<LocationsCubit, LocationsState>(
        'should emit loading and load locations when update succeeds',
        build: () {
          when(
            () => mockUpdateLocation.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.updateLocation(tLocation),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateLocation.call(tLocation)).called(1);
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should emit error when update fails',
        build: () {
          when(
            () => mockUpdateLocation.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) => cubit.updateLocation(tLocation),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateLocation.call(tLocation)).called(1);
          verifyNever(() => mockGetLocations.call(any()));
        },
      );
    });

    group('deleteLocation', () {
      final tId = faker.guid.guid();

      blocTest<LocationsCubit, LocationsState>(
        'should emit loading and load locations when delete succeeds',
        build: () {
          when(
            () => mockDeleteLocation.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.deleteLocation(tId),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteLocation.call(tId)).called(1);
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should emit error when delete fails',
        build: () {
          when(
            () => mockDeleteLocation.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) => cubit.deleteLocation(tId),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteLocation.call(tId)).called(1);
          verifyNever(() => mockGetLocations.call(any()));
        },
      );
    });

    group('createArea', () {
      final tArea = EntityFactory.makeAreaEntity();

      blocTest<LocationsCubit, LocationsState>(
        'should emit loading, loaded, and load areas when create succeeds',
        build: () {
          when(
            () => mockCreateArea.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.createArea(tArea),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateArea.call(tArea)).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should emit error when create fails',
        build: () {
          when(
            () => mockCreateArea.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) => cubit.createArea(tArea),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateArea.call(tArea)).called(1);
          verifyNever(() => mockGetAreas.call(any()));
        },
      );
    });

    group('updateArea', () {
      final tArea = EntityFactory.makeAreaEntity();

      blocTest<LocationsCubit, LocationsState>(
        'should emit loading, loaded, and load areas when update succeeds',
        build: () {
          when(
            () => mockUpdateArea.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.updateArea(tArea),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateArea.call(tArea)).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should emit error when update fails',
        build: () {
          when(
            () => mockUpdateArea.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) => cubit.updateArea(tArea),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateArea.call(tArea)).called(1);
          verifyNever(() => mockGetAreas.call(any()));
        },
      );
    });

    group('deleteArea', () {
      final tId = faker.guid.guid();
      final tLocationId = faker.guid.guid();

      blocTest<LocationsCubit, LocationsState>(
        'should emit loading, loaded, and load areas when delete succeeds',
        build: () {
          when(
            () => mockDeleteArea.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.deleteArea(tId, tLocationId),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteArea.call(tId)).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should emit error when delete fails',
        build: () {
          when(
            () => mockDeleteArea.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) => cubit.deleteArea(tId, tLocationId),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteArea.call(tId)).called(1);
          verifyNever(() => mockGetAreas.call(any()));
        },
      );
    });
  });
}
