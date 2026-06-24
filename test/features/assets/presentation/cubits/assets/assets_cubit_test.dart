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
          when(
            () => mockGetAssets.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssets));
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
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
        verify: (_) {
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );
      blocTest<AssetsCubit, AssetsState>(
        'should not emit loading when pass false parameter',
        build: () {
          final tAssets = EntityFactory.makeAssetEntityList();
          when(
            () => mockGetAssets.call(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssets));
          return cubit;
        },
        act: (cubit) => cubit.loadAssets(emitLoading: false),
        expect: () => [
          isA<AssetsState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.assets, 'assets', isNotEmpty)
              .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
        verify: (_) {
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit loading and error when assets load fails',
        build: () {
          final tMessage = faker.lorem.sentence();
          when(() => mockGetAssets.call(any())).thenAnswer(
            (_) async => FailureState<List<AssetEntity>>(message: tMessage),
          );
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

    group('saveAsset', () {
      final tAsset = EntityFactory.makeAssetEntity();

      blocTest<AssetsCubit, AssetsState>(
        'should call createAsset usecase, emit loading, and load assets when creation succeeds',
        build: () {
          when(
            () => mockCreateAsset.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAssets.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveAsset(
              id: null,
              companyId: tAsset.companyId,
              areaId: tAsset.areaId,
              categoryId: tAsset.categoryId != null ? '${tAsset.categoryId} ' : null,
              parentAssetId: tAsset.parentAssetId != null ? '${tAsset.parentAssetId} ' : null,
              name: '${tAsset.name} ',
              code: tAsset.code != null ? '${tAsset.code} ' : null,
              manufacturer: tAsset.manufacturer != null ? '${tAsset.manufacturer} ' : null,
              model: tAsset.model != null ? '${tAsset.model} ' : null,
              serialNumber: tAsset.serialNumber != null ? '${tAsset.serialNumber} ' : null,
              installDate: tAsset.installDate,
              warrantyExpiration: tAsset.warrantyExpiration,
              revisionForecast: tAsset.revisionForecast,
              status: tAsset.status,
              criticality: tAsset.criticality,
              notes: tAsset.notes != null ? '${tAsset.notes} ' : null,
            ),
            isTrue,
          );
        },
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockCreateAsset.call(
              any(
                that: isA<AssetEntity>()
                    .having((a) => a.companyId, 'companyId', tAsset.companyId)
                    .having((a) => a.areaId, 'areaId', tAsset.areaId)
                    .having((a) => a.name, 'name', tAsset.name.trim())
                    .having(
                      (a) => a.categoryId,
                      'categoryId',
                      tAsset.categoryId?.trim(),
                    )
                    .having(
                      (a) => a.parentAssetId,
                      'parentAssetId',
                      tAsset.parentAssetId?.trim(),
                    )
                    .having((a) => a.code, 'code', tAsset.code?.trim())
                    .having(
                      (a) => a.manufacturer,
                      'manufacturer',
                      tAsset.manufacturer?.trim(),
                    )
                    .having((a) => a.model, 'model', tAsset.model?.trim())
                    .having(
                      (a) => a.serialNumber,
                      'serialNumber',
                      tAsset.serialNumber?.trim(),
                    )
                    .having((a) => a.status, 'status', tAsset.status)
                    .having(
                      (a) => a.criticality,
                      'criticality',
                      tAsset.criticality,
                    )
                    .having((a) => a.notes, 'notes', tAsset.notes?.trim()),
              ),
            ),
          ).called(1);
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should call createAsset usecase and emit error when creation fails',
        build: () {
          when(
            () => mockCreateAsset.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Error'));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveAsset(
              id: null,
              companyId: tAsset.companyId,
              areaId: tAsset.areaId,
              categoryId: tAsset.categoryId != null ? '${tAsset.categoryId} ' : null,
              parentAssetId: tAsset.parentAssetId != null ? '${tAsset.parentAssetId} ' : null,
              name: '${tAsset.name} ',
              code: tAsset.code != null ? '${tAsset.code} ' : null,
              manufacturer: tAsset.manufacturer != null ? '${tAsset.manufacturer} ' : null,
              model: tAsset.model != null ? '${tAsset.model} ' : null,
              serialNumber: tAsset.serialNumber != null ? '${tAsset.serialNumber} ' : null,
              installDate: tAsset.installDate,
              warrantyExpiration: tAsset.warrantyExpiration,
              revisionForecast: tAsset.revisionForecast,
              status: tAsset.status,
              criticality: tAsset.criticality,
              notes: tAsset.notes != null ? '${tAsset.notes} ' : null,
            ),
            isFalse,
          );
        },
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateAsset.call(any())).called(1);
          verifyNever(() => mockGetAssets.call(any()));
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should call updateAsset usecase, emit saving, and load assets when update succeeds',
        build: () {
          when(
            () => mockUpdateAsset.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(
            () => mockGetAssets.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveAsset(
              id: tAsset.id,
              companyId: tAsset.companyId,
              areaId: tAsset.areaId,
              categoryId: tAsset.categoryId != null ? '${tAsset.categoryId} ' : null,
              parentAssetId: tAsset.parentAssetId != null ? '${tAsset.parentAssetId} ' : null,
              name: '${tAsset.name} ',
              code: tAsset.code != null ? '${tAsset.code} ' : null,
              manufacturer: tAsset.manufacturer != null ? '${tAsset.manufacturer} ' : null,
              model: tAsset.model != null ? '${tAsset.model} ' : null,
              serialNumber: tAsset.serialNumber != null ? '${tAsset.serialNumber} ' : null,
              installDate: tAsset.installDate,
              warrantyExpiration: tAsset.warrantyExpiration,
              revisionForecast: tAsset.revisionForecast,
              status: tAsset.status,
              criticality: tAsset.criticality,
              notes: tAsset.notes != null ? '${tAsset.notes} ' : null,
              createdAt: tAsset.createdAt,
            ),
            isTrue,
          );
        },
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockUpdateAsset.call(
              any(
                that: isA<AssetEntity>()
                    .having(
                      (a) => a.parentAssetId,
                      'parentAssetId',
                      tAsset.parentAssetId?.trim(),
                    )
                    .having(
                      (a) => a.categoryId,
                      'categoryId',
                      tAsset.categoryId?.trim(),
                    )
                    .having((a) => a.id, 'id', tAsset.id)
                    .having((a) => a.companyId, 'companyId', tAsset.companyId)
                    .having((a) => a.areaId, 'areaId', tAsset.areaId)
                    .having((a) => a.name, 'name', tAsset.name.trim())
                    .having((a) => a.code, 'code', tAsset.code?.trim())
                    .having(
                      (a) => a.manufacturer,
                      'manufacturer',
                      tAsset.manufacturer?.trim(),
                    )
                    .having((a) => a.model, 'model', tAsset.model?.trim())
                    .having(
                      (a) => a.serialNumber,
                      'serialNumber',
                      tAsset.serialNumber?.trim(),
                    )
                    .having((a) => a.status, 'status', tAsset.status)
                    .having(
                      (a) => a.criticality,
                      'criticality',
                      tAsset.criticality,
                    )
                    .having((a) => a.notes, 'notes', tAsset.notes?.trim())
                    .having((a) => a.createdAt, 'createdAt', tAsset.createdAt),
              ),
            ),
          ).called(1);
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should call updateAsset usecase and emit error when update fails',
        build: () {
          when(
            () => mockUpdateAsset.call(any()),
          ).thenAnswer((_) async => FailureState<bool>(message: 'Error'));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveAsset(
              id: tAsset.id,
              companyId: tAsset.companyId,
              areaId: tAsset.areaId,
              categoryId: tAsset.categoryId != null ? '${tAsset.categoryId} ' : null,
              parentAssetId: tAsset.parentAssetId != null ? '${tAsset.parentAssetId} ' : null,
              name: '${tAsset.name} ',
              code: tAsset.code != null ? '${tAsset.code} ' : null,
              manufacturer: tAsset.manufacturer != null ? '${tAsset.manufacturer} ' : null,
              model: tAsset.model != null ? '${tAsset.model} ' : null,
              serialNumber: tAsset.serialNumber != null ? '${tAsset.serialNumber} ' : null,
              installDate: tAsset.installDate,
              warrantyExpiration: tAsset.warrantyExpiration,
              revisionForecast: tAsset.revisionForecast,
              status: tAsset.status,
              criticality: tAsset.criticality,
              notes: tAsset.notes != null ? '${tAsset.notes} ' : null,
              createdAt: tAsset.createdAt,
            ),
            isFalse,
          );
        },
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            StateStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateAsset.call(any())).called(1);
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
            StateStatus.deleting,
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
            StateStatus.deleting,
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
