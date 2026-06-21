import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/create_asset_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/delete_asset_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/get_asset_by_id_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/update_asset_use_case.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit_use_cases.dart';
import 'package:clean_architecture/features/categories/domain/use_cases/get_categories_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/get_areas_use_case.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/get_locations_use_case.dart';
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

class MockGetAssetsUseCase extends Mock implements GetAssetsUseCase {}

class MockGetAssetByIdUseCase extends Mock implements GetAssetByIdUseCase {}

class MockCreateAssetUseCase extends Mock implements CreateAssetUseCase {}

class MockUpdateAssetUseCase extends Mock implements UpdateAssetUseCase {}

class MockDeleteAssetUseCase extends Mock implements DeleteAssetUseCase {}

class MockGetLocationsUseCase extends Mock implements GetLocationsUseCase {}

class MockGetAreasUseCase extends Mock implements GetAreasUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetSessionUserUseCase mockGetSessionUser;
  late MockGetAssetsUseCase mockGetAssets;
  late MockGetAssetByIdUseCase mockGetAssetById;
  late MockCreateAssetUseCase mockCreateAsset;
  late MockUpdateAssetUseCase mockUpdateAsset;
  late MockDeleteAssetUseCase mockDeleteAsset;
  late MockGetLocationsUseCase mockGetLocations;
  late MockGetAreasUseCase mockGetAreas;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockNavigationClient mockNavigationClient;

  late AssetsCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeAssetEntity());
  });

  setUp(() {
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockGetAssets = MockGetAssetsUseCase();
    mockGetAssetById = MockGetAssetByIdUseCase();
    mockCreateAsset = MockCreateAssetUseCase();
    mockUpdateAsset = MockUpdateAssetUseCase();
    mockDeleteAsset = MockDeleteAssetUseCase();
    mockGetLocations = MockGetLocationsUseCase();
    mockGetAreas = MockGetAreasUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();
    when(() => mockGetSessionUser.call()).thenReturn(tUserProfile);

    final useCases = AssetsCubitUseCases(
      getSessionUser: mockGetSessionUser,
      getAssets: mockGetAssets,
      getAssetById: mockGetAssetById,
      createAsset: mockCreateAsset,
      updateAsset: mockUpdateAsset,
      deleteAsset: mockDeleteAsset,
      getLocations: mockGetLocations,
      getAreas: mockGetAreas,
      getCategories: mockGetCategories,
    );

    cubit = AssetsCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('AssetsCubit Tests', () {
    group('loadAssets', () {
      blocTest<AssetsCubit, AssetsState>(
        'should emit loading and loaded when assets load successfully',
        build: () {
          final tAssets = EntityFactory.makeAssetEntityList();
          final tLocations = EntityFactory.makeLocationEntityList();
          final tAreas = EntityFactory.makeAreaEntityList();
          final tCategories = EntityFactory.makeCategoryEntityList();
          when(
            () => mockGetAssets.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssets));
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tLocations));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreas));
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tCategories));
          return cubit;
        },
        act: (cubit) => cubit.loadAssets(),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.assets, 'assets', isNotEmpty)
              .having((s) => s.locations, 'locations', isNotEmpty)
              .having((s) => s.areas, 'areas', isNotEmpty)
              .having((s) => s.categories, 'categories', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
        verify: (_) {
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
          verify(
            () => mockGetCategories.call(tUserProfile.companyId),
          ).called(1);
        },
      );
      blocTest<AssetsCubit, AssetsState>(
        'should not emit loading when pass false parameter',
        build: () {
          final tAssets = EntityFactory.makeAssetEntityList();
          final tLocations = EntityFactory.makeLocationEntityList();
          final tAreas = EntityFactory.makeAreaEntityList();
          final tCategories = EntityFactory.makeCategoryEntityList();
          when(
            () => mockGetAssets.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssets));
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tLocations));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAreas));
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tCategories));
          return cubit;
        },
        act: (cubit) => cubit.loadAssets(emitLoading: false),
        expect: () => [
          isA<AssetsState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.assets, 'assets', isNotEmpty)
              .having((s) => s.locations, 'locations', isNotEmpty)
              .having((s) => s.areas, 'areas', isNotEmpty)
              .having((s) => s.categories, 'categories', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
        verify: (_) {
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
          verify(() => mockGetLocations.call(tUserProfile.companyId)).called(1);
          verify(() => mockGetAreas.call(tUserProfile.companyId)).called(1);
          verify(
            () => mockGetCategories.call(tUserProfile.companyId),
          ).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit loading and error when assets load fails',
        build: () {
          final tMessage = faker.lorem.sentence();
          when(() => mockGetAssets.call(any())).thenAnswer(
            (_) async => FailureState<List<AssetEntity>>(message: tMessage),
          );
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.loadAssets(),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>()
              .having((s) => s.status, 'status', StateStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit error when companyId is empty',
        build: () {
          final emptyUser = tUserProfile.copyWith(annulCompanyId: true);
          when(() => mockGetSessionUser.call()).thenReturn(emptyUser);
          return cubit;
        },
        act: (cubit) => cubit.loadAssets(),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verifyNever(() => mockGetAssets.call(any()));
        },
      );
    });

    group('createAsset', () {
      final tAsset = EntityFactory.makeAssetEntity();

      blocTest<AssetsCubit, AssetsState>(
        'should emit loading, load assets, and show success toast when create succeeds',
        build: () {
          when(
            () => mockCreateAsset.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAssets.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetLocations.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetAreas.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          when(
            () => mockGetCategories.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async => expect(await cubit.createAsset(tAsset), isTrue),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateAsset.call(tAsset)).called(1);
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit error and show failure toast when create fails',
        build: () {
          when(
            () => mockCreateAsset.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Error'));
          return cubit;
        },
        act: (cubit) async => expect(await cubit.createAsset(tAsset), isFalse),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateAsset.call(tAsset)).called(1);
          verifyNever(() => mockGetAssets.call(any()));
        },
      );
    });

    group('updateAsset', () {
      final tAsset = EntityFactory.makeAssetEntity();

      blocTest<AssetsCubit, AssetsState>(
        'should emit loading, load assets, and show success toast when update succeeds',
        build: () {
          when(
            () => mockUpdateAsset.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAssets.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.updateAsset(tAsset),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateAsset.call(tAsset)).called(1);
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit error and show failure toast when update fails',
        build: () {
          when(
            () => mockUpdateAsset.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Error'));
          return cubit;
        },
        act: (cubit) => cubit.updateAsset(tAsset),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateAsset.call(tAsset)).called(1);
          verifyNever(() => mockGetAssets.call(any()));
        },
      );
    });

    group('deleteAsset', () {
      final tId = faker.guid.guid();

      blocTest<AssetsCubit, AssetsState>(
        'should emit loading, load assets, and show success toast when delete succeeds',
        build: () {
          when(
            () => mockDeleteAsset.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAssets.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.deleteAsset(tId),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteAsset.call(tId)).called(1);
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit error and show failure toast when delete fails',
        build: () {
          when(
            () => mockDeleteAsset.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Error'));
          return cubit;
        },
        act: (cubit) => cubit.deleteAsset(tId),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteAsset.call(tId)).called(1);
          verifyNever(() => mockGetAssets.call(any()));
        },
      );
    });
  });
}
