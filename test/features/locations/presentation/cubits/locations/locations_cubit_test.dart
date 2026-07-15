import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/create_area_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/create_location_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/delete_area_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/delete_location_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_areas_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_locations_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/update_area_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/update_location_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

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

  late List<LocationEntity> tLocations;
  late List<AreaEntity> tAreas;

  late LocationsCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeLocationEntity());
    registerFallbackValue(EntityFactory.makeAreaEntity());
    registerFallbackValue(CreateUpdateAreaRoute(locationId: '', companyId: ''));
    registerFallbackValue(CreateUpdateLocationRoute());
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
    tLocations = EntityFactory.makeLocationEntityList();
    tAreas = EntityFactory.makeAreaEntityList();

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
              .having((s) => s.errorMessage, 'errorMessage', isNull)
              .having((s) => s.locations, 'locations', isNotEmpty)
              .having((s) => s.allAreas, 'allAreas', tAreas),
        ],
        verify: (_) {
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );
      blocTest<LocationsCubit, LocationsState>(
        'should not emit loading when pass a false value',
        build: () {
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tLocations));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreas));
          return cubit;
        },
        act: (cubit) => cubit.loadLocationsAndAreas(showLoading: false),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.initial,
          ),
          isA<LocationsState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.errorMessage, 'errorMessage', isNull)
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
              .having((s) => s.status, 'status', StateStatus.loadingError)
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
            StateStatus.loadingError,
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
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreas));
          return cubit;
        },
        act: (cubit) => cubit.loadAreas(tUserProfile.companyId),
        expect: () => [
          isA<LocationsState>()
              .having((s) => s.areasByLocation, 'areasByLocation', isNotEmpty)
              .having((s) => s.allAreas, 'allAreas', tAreas),
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

    group('saveLocation', () {
      final tLocation = EntityFactory.makeLocationEntity();

      blocTest<LocationsCubit, LocationsState>(
        'should call createLocation usecase, emit saving and load locations when creation succeeds',
        build: () {
          when(
            () => mockCreateLocation.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveLocation(
              id: null,
              companyId: tLocation.companyId,
              name: '${tLocation.name} ',
              postalCode: '${tLocation.postalCode} ',
              address: '${tLocation.address} ',
              number: '${tLocation.number} ',
              complement: '${tLocation.complement} ',
              neighborhood: '${tLocation.neighborhood} ',
              city: '${tLocation.city} ',
              addressState: '${tLocation.state} ',
            ),
            isTrue,
          );
        },
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockCreateLocation.call(
              any(
                that: isA<LocationEntity>()
                    .having(
                      (l) => l.companyId,
                      'companyId',
                      tLocation.companyId,
                    )
                    .having((l) => l.name, 'name', tLocation.name.trim())
                    .having(
                      (l) => l.postalCode,
                      'postalCode',
                      tLocation.postalCode?.trim(),
                    )
                    .having(
                      (l) => l.address,
                      'address',
                      tLocation.address?.trim(),
                    )
                    .having((l) => l.number, 'number', tLocation.number?.trim())
                    .having(
                      (l) => l.complement,
                      'complement',
                      tLocation.complement?.trim(),
                    )
                    .having(
                      (l) => l.neighborhood,
                      'neighborhood',
                      tLocation.neighborhood?.trim(),
                    )
                    .having((l) => l.city, 'city', tLocation.city?.trim())
                    .having((l) => l.state, 'state', tLocation.state?.trim())
                    .having((l) => l.isActive, 'isActive', true),
              ),
            ),
          ).called(1);
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should call createLocation usecase and emit error when creation fails',
        build: () {
          when(
            () => mockCreateLocation.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveLocation(
              id: null,
              companyId: tLocation.companyId,
              name: tLocation.name,
              postalCode: tLocation.postalCode,
              address: tLocation.address,
              number: tLocation.number,
              complement: tLocation.complement,
              neighborhood: tLocation.neighborhood,
              city: tLocation.city,
              addressState: tLocation.state,
            ),
            isFalse,
          );
        },
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.savingError,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateLocation.call(any())).called(1);
          verifyNever(() => mockGetLocations.call(any()));
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should call updateLocation usecase and emit loading and load locations when update succeeds',
        build: () {
          when(
            () => mockUpdateLocation.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveLocation(
              id: tLocation.id,
              companyId: tLocation.companyId,
              name: '${tLocation.name} ',
              postalCode: '${tLocation.postalCode} ',
              address: '${tLocation.address} ',
              number: '${tLocation.number} ',
              complement: '${tLocation.complement} ',
              neighborhood: '${tLocation.neighborhood} ',
              city: '${tLocation.city} ',
              addressState: '${tLocation.state} ',
              createdAt: tLocation.createdAt,
            ),
            isTrue,
          );
        },
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockUpdateLocation.call(
              any(
                that: isA<LocationEntity>()
                    .having((l) => l.id, 'id', tLocation.id)
                    .having(
                      (l) => l.companyId,
                      'companyId',
                      tLocation.companyId,
                    )
                    .having((l) => l.name, 'name', tLocation.name.trim())
                    .having(
                      (l) => l.postalCode,
                      'postalCode',
                      tLocation.postalCode?.trim(),
                    )
                    .having(
                      (l) => l.address,
                      'address',
                      tLocation.address?.trim(),
                    )
                    .having((l) => l.number, 'number', tLocation.number?.trim())
                    .having(
                      (l) => l.complement,
                      'complement',
                      tLocation.complement?.trim(),
                    )
                    .having(
                      (l) => l.neighborhood,
                      'neighborhood',
                      tLocation.neighborhood?.trim(),
                    )
                    .having((l) => l.city, 'city', tLocation.city?.trim())
                    .having((l) => l.state, 'state', tLocation.state?.trim())
                    .having((l) => l.isActive, 'isActive', true)
                    .having(
                      (l) => l.createdAt,
                      'createdAt',
                      tLocation.createdAt,
                    ),
              ),
            ),
          ).called(1);
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should call updateLocation usecase and emit error when update fails',
        build: () {
          when(
            () => mockUpdateLocation.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveLocation(
              id: tLocation.id,
              companyId: tLocation.companyId,
              name: tLocation.name,
              postalCode: tLocation.postalCode,
              address: tLocation.address,
              number: tLocation.number,
              complement: tLocation.complement,
              neighborhood: tLocation.neighborhood,
              city: tLocation.city,
              addressState: tLocation.state,
              createdAt: tLocation.createdAt,
            ),
            isFalse,
          );
        },
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.savingError,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateLocation.call(any())).called(1);
          verifyNever(() => mockGetLocations.call(any()));
        },
      );
    });

    group('deleteLocation', () {
      final tId = faker.guid.guid();

      blocTest<LocationsCubit, LocationsState>(
        'should emit loading, initial and loaded when delete succeeds',
        build: () {
          when(
            () => mockDeleteLocation.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.deleteLocation(tId),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.deleting,
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
            StateStatus.deleting,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.deletingError,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteLocation.call(tId)).called(1);
          verifyNever(() => mockGetLocations.call(any()));
        },
      );
    });

    group('saveArea', () {
      final tArea = EntityFactory.makeAreaEntity();

      blocTest<LocationsCubit, LocationsState>(
        'should call createArea usecase, emit saving, and load areas when creation succeeds',
        build: () {
          when(
            () => mockCreateArea.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveArea(
              id: null,
              locationId: tArea.locationId,
              companyId: tArea.companyId,
              name: '${tArea.name} ',
              floor: '${tArea.floor} ',
              description: '${tArea.description} ',
            ),
            isTrue,
          );
        },
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockCreateArea.call(
              any(
                that: isA<AreaEntity>()
                    .having((a) => a.locationId, 'locationId', tArea.locationId)
                    .having((a) => a.companyId, 'companyId', tArea.companyId)
                    .having((a) => a.name, 'name', tArea.name.trim())
                    .having((a) => a.floor, 'floor', tArea.floor?.trim())
                    .having(
                      (a) => a.description,
                      'description',
                      tArea.description?.trim(),
                    ),
              ),
            ),
          ).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should call createArea usecase and emit error when creation fails',
        build: () {
          when(
            () => mockCreateArea.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveArea(
              id: null,
              locationId: tArea.locationId,
              companyId: tArea.companyId,
              name: '${tArea.name} ',
              floor: '${tArea.floor} ',
              description: '${tArea.description} ',
            ),
            isFalse,
          );
        },
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.savingError,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateArea.call(any())).called(1);
          verifyNever(() => mockGetAreas.call(any()));
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should call updateArea usecase, emit saving, and load areas when update succeeds',
        build: () {
          when(
            () => mockUpdateArea.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveArea(
              id: tArea.id,
              locationId: tArea.locationId,
              companyId: tArea.companyId,
              name: '${tArea.name} ',
              floor: '${tArea.floor} ',
              description: '${tArea.description} ',
              createdAt: tArea.createdAt,
            ),
            isTrue,
          );
        },
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockUpdateArea.call(
              any(
                that: isA<AreaEntity>()
                    .having((a) => a.id, 'id', tArea.id)
                    .having((a) => a.locationId, 'locationId', tArea.locationId)
                    .having((a) => a.companyId, 'companyId', tArea.companyId)
                    .having((a) => a.name, 'name', tArea.name.trim())
                    .having((a) => a.floor, 'floor', tArea.floor?.trim())
                    .having(
                      (a) => a.description,
                      'description',
                      tArea.description?.trim(),
                    )
                    .having((a) => a.createdAt, 'createdAt', tArea.createdAt),
              ),
            ),
          ).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'should call updateArea usecase and emit error when update fails',
        build: () {
          when(
            () => mockUpdateArea.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Fail'));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveArea(
              id: tArea.id,
              locationId: tArea.locationId,
              companyId: tArea.companyId,
              name: '${tArea.name} ',
              floor: '${tArea.floor} ',
              description: '${tArea.description} ',
              createdAt: tArea.createdAt,
            ),
            isFalse,
          );
        },
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.savingError,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateArea.call(any())).called(1);
          verifyNever(() => mockGetAreas.call(any()));
        },
      );
    });

    group('deleteArea', () {
      final tId = faker.guid.guid();
      final tLocationId = faker.guid.guid();

      blocTest<LocationsCubit, LocationsState>(
        'should emit deleting, loaded, and load areas when delete succeeds',
        build: () {
          when(
            () => mockDeleteArea.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async =>
            expect(await cubit.deleteArea(tId, tLocationId), isTrue),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.deleting,
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
        act: (cubit) async =>
            expect(await cubit.deleteArea(tId, tLocationId), isFalse),
        expect: () => [
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.deleting,
          ),
          isA<LocationsState>().having(
            (s) => s.status,
            'status',
            StateStatus.deletingError,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteArea.call(tId)).called(1);
          verifyNever(() => mockGetAreas.call(any()));
        },
      );
    });

    group('Navigation', () {
      final tArea = faker.randomGenerator.boolean()
          ? EntityFactory.makeAreaEntity()
          : null;
      final tLocation = faker.randomGenerator.boolean()
          ? EntityFactory.makeLocationEntity()
          : null;

      blocTest<LocationsCubit, LocationsState>(
        'navigateToCreateUpdateArea should push CreateUpdateAreaRoute',
        build: () {
          when(
            () => mockNavigationClient.pushRoute<CreateUpdateAreaRouteArgs>(
              any(),
            ),
          ).thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) => cubit.navigateToCreateUpdateArea(
          locationId: 'loc1',
          companyId: 'comp1',
          area: tArea,
        ),
        expect: () => <LocationsState>[],
        verify: (cubit) {
          verify(
            () => mockNavigationClient.pushRoute<CreateUpdateAreaRouteArgs>(
              any(),
            ),
          ).called(1);
        },
      );

      blocTest<LocationsCubit, LocationsState>(
        'navigateToCreateUpdateLocation should push CreateUpdateLocationRoute',
        build: () {
          when(
            () => mockNavigationClient.pushRoute<CreateUpdateLocationRouteArgs>(
              any(),
            ),
          ).thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) =>
            cubit.navigateToCreateUpdateLocation(existingLocation: tLocation),
        expect: () => <LocationsState>[],
        verify: (cubit) {
          verify(
            () => mockNavigationClient.pushRoute<CreateUpdateLocationRouteArgs>(
              any(),
            ),
          ).called(1);
        },
      );

      test('popRoute should call popRouteAdaptively', () {
        when(
          () => mockNavigationClient.maybePop(),
        ).thenAnswer((_) async => true);
        cubit.popRoute();
        verify(() => mockNavigationClient.maybePop()).called(1);
      });
    });
  });
}
