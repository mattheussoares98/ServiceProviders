import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/create_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/delete_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_asset_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_assets_by_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/update_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/features/categories/domain/use_cases/get_categories_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_areas_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/get_locations_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
import '../../../../../../testing/mocks/entity_factory.dart';
import '../../../../../../testing/mocks/use_case_mocks.dart';

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockGetAssetsUseCase extends Mock implements GetAssetsUseCase {}

class MockGetAssetsByIdsUseCase extends Mock implements GetAssetsByIdsUseCase {}

class MockGetAssetByIdUseCase extends Mock implements GetAssetByIdUseCase {}

class MockCreateAssetUseCase extends Mock implements CreateAssetUseCase {}

class MockUpdateAssetUseCase extends Mock implements UpdateAssetUseCase {}

class MockDeleteAssetUseCase extends Mock implements DeleteAssetUseCase {}

class MockGetLocationsUseCase extends Mock implements GetLocationsUseCase {}

class MockGetAreasUseCase extends Mock implements GetAreasUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockGetAssetsUseCase mockGetAssets;
  late MockGetAssetsByIdsUseCase mockGetAssetsByIds;
  late MockGetAssetByIdUseCase mockGetAssetById;
  late MockCreateAssetUseCase mockCreateAsset;
  late MockUpdateAssetUseCase mockUpdateAsset;
  late MockDeleteAssetUseCase mockDeleteAsset;
  late MockWatchAssetsRealtimeUseCase mockWatchAssetsRealtime;
  late MockNavigationClient mockNavigationClient;
  late MockGetActiveCompanyIdUseCase mockGetActiveCompanyIdUseCase;

  late AssetsCubit cubit;
  late UserProfileEntity tUserProfile;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeAssetEntity());
    registerFallbackValue(CreateUpdateAssetRoute());
  });

  setUp(() {
    mockGetAssets = MockGetAssetsUseCase();
    mockGetAssetsByIds = MockGetAssetsByIdsUseCase();
    mockGetAssetById = MockGetAssetByIdUseCase();
    mockCreateAsset = MockCreateAssetUseCase();
    mockUpdateAsset = MockUpdateAssetUseCase();
    mockDeleteAsset = MockDeleteAssetUseCase();
    mockWatchAssetsRealtime = MockWatchAssetsRealtimeUseCase();
    mockNavigationClient = MockNavigationClient();
    mockGetActiveCompanyIdUseCase = MockGetActiveCompanyIdUseCase();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    tUserProfile = EntityFactory.makeUserProfileEntity();
    when(
      () => mockGetActiveCompanyIdUseCase.call(),
    ).thenReturn(tUserProfile.companyId);
    when(
      () => mockWatchAssetsRealtime.call(companyId: any(named: 'companyId')),
    ).thenAnswer((_) => const Stream.empty());

    final useCases = AssetsCubitUseCases(
      getAssets: mockGetAssets,
      getAssetsByIds: mockGetAssetsByIds,
      getAssetById: mockGetAssetById,
      createAsset: mockCreateAsset,
      updateAsset: mockUpdateAsset,
      deleteAsset: mockDeleteAsset,
      getActiveCompanyId: mockGetActiveCompanyIdUseCase,
      watchAssetsRealtime: mockWatchAssetsRealtime,
    );

    cubit = AssetsCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('AssetsCubit Tests', () {
    group('loadAssetsByIds', () {
      blocTest<AssetsCubit, AssetsState>(
        'should emit loaded with the assets referenced by the ids',
        build: () {
          when(() => mockGetAssetsByIds.call(any())).thenAnswer(
            (_) async =>
                SuccessState(data: EntityFactory.makeAssetEntityList()),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadAssetsByIds([faker.guid.guid()]),
        expect: () => [
          isA<AssetsState>()
              .having((s) => s.status, 'status', DataStatus.loaded)
              .having((s) => s.assets, 'assets', isNotEmpty),
        ],
      );

      blocTest<AssetsCubit, AssetsState>(
        'should not call the use case nor emit when the id list is empty',
        build: () => cubit,
        act: (cubit) => cubit.loadAssetsByIds([]),
        expect: () => <AssetsState>[],
        verify: (_) {
          verifyNever(() => mockGetAssetsByIds.call(any()));
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should stay silent on failure — these are optional labels',
        build: () {
          when(() => mockGetAssetsByIds.call(any())).thenAnswer(
            (_) async => FailureState<List<AssetEntity>>(message: 'Error'),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadAssetsByIds([faker.guid.guid()]),
        expect: () => <AssetsState>[],
      );
    });

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
            DataStatus.loading,
          ),
          isA<AssetsState>()
              .having((s) => s.status, 'status', DataStatus.loaded)
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
              .having((s) => s.status, 'status', DataStatus.loaded)
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
            DataStatus.loading,
          ),
          isA<AssetsState>()
              .having((s) => s.status, 'status', DataStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit error when companyId is empty',
        build: () {
          when(
            () => mockGetAssets.call(''),
          ).thenAnswer((_) async => FailureState(message: 'Error'));
          when(mockGetActiveCompanyIdUseCase.call).thenReturn('');
          return cubit;
        },
        act: (cubit) => cubit.loadAssets(),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            DataStatus.loadingError,
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
              areaId: tAsset.areaId,
              categoryId: tAsset.categoryId != null
                  ? '${tAsset.categoryId} '
                  : null,
              parentAssetId: tAsset.parentAssetId != null
                  ? '${tAsset.parentAssetId} '
                  : null,
              name: '${tAsset.name} ',
              code: tAsset.code != null ? '${tAsset.code} ' : null,
              manufacturer: tAsset.manufacturer != null
                  ? '${tAsset.manufacturer} '
                  : null,
              model: tAsset.model != null ? '${tAsset.model} ' : null,
              serialNumber: tAsset.serialNumber != null
                  ? '${tAsset.serialNumber} '
                  : null,
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
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.running,
          ),
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.success,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            DataStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockCreateAsset.call(
              any(
                that: isA<AssetEntity>()
                    .having(
                      (a) => a.companyId,
                      'companyId',
                      tUserProfile.companyId,
                    )
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
              areaId: tAsset.areaId,
              categoryId: tAsset.categoryId != null
                  ? '${tAsset.categoryId} '
                  : null,
              parentAssetId: tAsset.parentAssetId != null
                  ? '${tAsset.parentAssetId} '
                  : null,
              name: '${tAsset.name} ',
              code: tAsset.code != null ? '${tAsset.code} ' : null,
              manufacturer: tAsset.manufacturer != null
                  ? '${tAsset.manufacturer} '
                  : null,
              model: tAsset.model != null ? '${tAsset.model} ' : null,
              serialNumber: tAsset.serialNumber != null
                  ? '${tAsset.serialNumber} '
                  : null,
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
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.running,
          ),
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.error,
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
              areaId: tAsset.areaId,
              categoryId: tAsset.categoryId != null
                  ? '${tAsset.categoryId} '
                  : null,
              parentAssetId: tAsset.parentAssetId != null
                  ? '${tAsset.parentAssetId} '
                  : null,
              name: '${tAsset.name} ',
              code: tAsset.code != null ? '${tAsset.code} ' : null,
              manufacturer: tAsset.manufacturer != null
                  ? '${tAsset.manufacturer} '
                  : null,
              model: tAsset.model != null ? '${tAsset.model} ' : null,
              serialNumber: tAsset.serialNumber != null
                  ? '${tAsset.serialNumber} '
                  : null,
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
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.running,
          ),
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.success,
          ),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            DataStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(
            () => mockUpdateAsset.call(
              any(
                that: isA<AssetEntity>()
                    .having(
                      (a) => a.companyId,
                      'companyId',
                      tUserProfile.companyId,
                    )
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
        'should emit error when update fails on saveAsset',
        build: () {
          when(
            () => mockUpdateAsset.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveAsset(
              id: tAsset.id,
              areaId: tAsset.areaId,
              status: tAsset.status,
              criticality: tAsset.criticality,
              name: tAsset.name,
            ),
            isFalse,
          );
        },
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.running,
          ),
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateAsset.call(any())).called(1);
          verifyNever(() => mockGetAssets.call(any()));
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit error and return false when companyId is empty on saveAsset',
        build: () {
          when(
            () => mockUpdateAsset.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error'));
          return cubit;
        },
        act: (cubit) async {
          expect(
            await cubit.saveAsset(
              id: tAsset.id,
              areaId: tAsset.areaId,
              status: tAsset.status,
              criticality: tAsset.criticality,
              name: tAsset.name,
            ),
            isFalse,
          );
        },
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.running,
          ),
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.save],
            'sections[save]',
            SectionStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateAsset.call(any())).called(1);
          verifyNever(() => mockCreateAsset.call(any()));
          verifyNever(() => mockGetAssets.call(any()));
        },
      );
    });

    group('deleteAsset', () {
      final tAsset = EntityFactory.makeAssetEntity();
      final tId = tAsset.id;

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
        seed: () => cubit.state.copyWith(assets: [tAsset]),
        act: (cubit) async =>
            expect(await cubit.deleteAsset(tAsset.id), isTrue),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.delete],
            'sections[delete]',
            SectionStatus.running,
          ),
          isA<AssetsState>()
              .having(
                (s) => s.sections[AssetsSections.delete],
                'sections[delete]',
                SectionStatus.success,
              )
              .having((s) => s.assets, 'assets', isEmpty),
          isA<AssetsState>().having(
            (s) => s.status,
            'status',
            DataStatus.loaded,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteAsset.call(tAsset.id)).called(1);
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
        act: (cubit) async => expect(await cubit.deleteAsset(tId), isFalse),
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.delete],
            'sections[delete]',
            SectionStatus.running,
          ),
          isA<AssetsState>().having(
            (s) => s.sections[AssetsSections.delete],
            'sections[delete]',
            SectionStatus.error,
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteAsset.call(tId)).called(1);
          verifyNever(() => mockGetAssets.call(any()));
        },
      );
    });

    group('Navigation', () {
      final tAsset = faker.randomGenerator.boolean()
          ? EntityFactory.makeAssetEntity()
          : null;

      blocTest<AssetsCubit, AssetsState>(
        'navigateToCreateUpdateAsset should push CreateUpdateAssetRoute',
        build: () {
          when(
            () => mockNavigationClient.pushRoute<CreateUpdateAssetRouteArgs>(
              any(),
            ),
          ).thenAnswer((_) async => null);
          return cubit;
        },
        act: (cubit) => cubit.navigateToCreateUpdateAsset(tAsset),
        expect: () => <AssetsState>[],
        verify: (cubit) {
          verify(
            () => mockNavigationClient.pushRoute<CreateUpdateAssetRouteArgs>(
              any(),
            ),
          ).called(1);
        },
      );
    });

    group('Realtime Events', () {
      final tInitialAsset = EntityFactory.makeAssetEntity();
      final tNewAsset = EntityFactory.makeAssetEntity();

      blocTest<AssetsCubit, AssetsState>(
        'prepends new asset on insert event',
        build: () {
          final streamController =
              StreamController<RealtimeEvent<AssetEntity>>();
          when(
            () => mockWatchAssetsRealtime.call(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => streamController.stream);

          final testCubit = AssetsCubit(
            useCases: AssetsCubitUseCases(
              getAssets: mockGetAssets,
              getAssetsByIds: mockGetAssetsByIds,
              getAssetById: mockGetAssetById,
              createAsset: mockCreateAsset,
              updateAsset: mockUpdateAsset,
              deleteAsset: mockDeleteAsset,
              getActiveCompanyId: mockGetActiveCompanyIdUseCase,
              watchAssetsRealtime: mockWatchAssetsRealtime,
            ),
          );

          testCubit.emit(
            testCubit.state.copyWith(
              status: DataStatus.loaded,
              assets: [tInitialAsset],
            ),
          );

          streamController.add(
            RealtimeEvent<AssetEntity>(
              eventType: RealtimeEventType.insert,
              id: tNewAsset.id,
              companyId: tUserProfile.companyId,
              entity: tNewAsset,
            ),
          );

          return testCubit;
        },
        expect: () => [
          isA<AssetsState>().having((s) => s.assets, 'assets', [
            tNewAsset,
            tInitialAsset,
          ]),
        ],
      );

      blocTest<AssetsCubit, AssetsState>(
        'updates existing asset in-place on update event',
        build: () {
          final streamController =
              StreamController<RealtimeEvent<AssetEntity>>();
          when(
            () => mockWatchAssetsRealtime.call(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => streamController.stream);

          final testCubit = AssetsCubit(
            useCases: AssetsCubitUseCases(
              getAssets: mockGetAssets,
              getAssetsByIds: mockGetAssetsByIds,
              getAssetById: mockGetAssetById,
              createAsset: mockCreateAsset,
              updateAsset: mockUpdateAsset,
              deleteAsset: mockDeleteAsset,
              getActiveCompanyId: mockGetActiveCompanyIdUseCase,
              watchAssetsRealtime: mockWatchAssetsRealtime,
            ),
          );

          testCubit.emit(
            testCubit.state.copyWith(
              status: DataStatus.loaded,
              assets: [tInitialAsset],
            ),
          );

          final updatedAsset = tInitialAsset.copyWith(name: 'Updated Asset');

          streamController.add(
            RealtimeEvent<AssetEntity>(
              eventType: RealtimeEventType.update,
              id: tInitialAsset.id,
              companyId: tUserProfile.companyId,
              entity: updatedAsset,
            ),
          );

          return testCubit;
        },
        expect: () => [
          isA<AssetsState>().having(
            (s) => s.assets.first.name,
            'asset name',
            'Updated Asset',
          ),
        ],
      );

      blocTest<AssetsCubit, AssetsState>(
        'removes asset on update event when deletedAt is not null',
        build: () {
          final streamController =
              StreamController<RealtimeEvent<AssetEntity>>();
          when(
            () => mockWatchAssetsRealtime.call(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => streamController.stream);

          final testCubit = AssetsCubit(
            useCases: AssetsCubitUseCases(
              getAssets: mockGetAssets,
              getAssetsByIds: mockGetAssetsByIds,
              getAssetById: mockGetAssetById,
              createAsset: mockCreateAsset,
              updateAsset: mockUpdateAsset,
              deleteAsset: mockDeleteAsset,
              getActiveCompanyId: mockGetActiveCompanyIdUseCase,
              watchAssetsRealtime: mockWatchAssetsRealtime,
            ),
          );

          testCubit.emit(
            testCubit.state.copyWith(
              status: DataStatus.loaded,
              assets: [tInitialAsset],
            ),
          );

          final softDeletedAsset = tInitialAsset.copyWith(
            deletedAt: DateTime.now(),
          );

          streamController.add(
            RealtimeEvent<AssetEntity>(
              eventType: RealtimeEventType.update,
              id: tInitialAsset.id,
              companyId: tUserProfile.companyId,
              entity: softDeletedAsset,
            ),
          );

          return testCubit;
        },
        expect: () => [
          isA<AssetsState>().having((s) => s.assets, 'assets', isEmpty),
        ],
      );

      blocTest<AssetsCubit, AssetsState>(
        'removes asset on delete event',
        build: () {
          final streamController =
              StreamController<RealtimeEvent<AssetEntity>>();
          when(
            () => mockWatchAssetsRealtime.call(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => streamController.stream);

          final testCubit = AssetsCubit(
            useCases: AssetsCubitUseCases(
              getAssets: mockGetAssets,
              getAssetsByIds: mockGetAssetsByIds,
              getAssetById: mockGetAssetById,
              createAsset: mockCreateAsset,
              updateAsset: mockUpdateAsset,
              deleteAsset: mockDeleteAsset,
              getActiveCompanyId: mockGetActiveCompanyIdUseCase,
              watchAssetsRealtime: mockWatchAssetsRealtime,
            ),
          );

          testCubit.emit(
            testCubit.state.copyWith(
              status: DataStatus.loaded,
              assets: [tInitialAsset],
            ),
          );

          streamController.add(
            RealtimeEvent<AssetEntity>(
              eventType: RealtimeEventType.delete,
              id: tInitialAsset.id,
              companyId: tUserProfile.companyId,
            ),
          );

          return testCubit;
        },
        expect: () => [
          isA<AssetsState>().having((s) => s.assets, 'assets', isEmpty),
        ],
      );
    });
  });
}
