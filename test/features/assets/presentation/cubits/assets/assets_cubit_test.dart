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
          when(() => mockGetAssets.call(any()))
              .thenAnswer((_) async => SuccessState(data: tAssets));
          return cubit;
        },
        act: (cubit) => cubit.loadAssets(),
        expect: () => [
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.assets, 'assets', isNotEmpty),
        ],
        verify: (_) {
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit loading and error when assets load fails',
        build: () {
          final tMessage = faker.lorem.sentence();
          when(() => mockGetAssets.call(any()))
              .thenAnswer((_) async => FailureState<List<AssetEntity>>(message: tMessage));
          return cubit;
        },
        act: (cubit) => cubit.loadAssets(),
        expect: () => [
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
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
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.error),
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
          when(() => mockCreateAsset.call(any()))
              .thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetAssets.call(any()))
              .thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.createAsset(tAsset),
        expect: () => [
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loaded),
        ],
        verify: (_) {
          verify(() => mockCreateAsset.call(tAsset)).called(1);
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit error and show failure toast when create fails',
        build: () {
          when(() => mockCreateAsset.call(any()))
              .thenAnswer((_) async => FailureState<bool>(message: 'Error'));
          return cubit;
        },
        act: (cubit) => cubit.createAsset(tAsset),
        expect: () => [
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.error),
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
          when(() => mockUpdateAsset.call(any()))
              .thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetAssets.call(any()))
              .thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.updateAsset(tAsset),
        expect: () => [
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loaded),
        ],
        verify: (_) {
          verify(() => mockUpdateAsset.call(tAsset)).called(1);
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit error and show failure toast when update fails',
        build: () {
          when(() => mockUpdateAsset.call(any()))
              .thenAnswer((_) async => FailureState<bool>(message: 'Error'));
          return cubit;
        },
        act: (cubit) => cubit.updateAsset(tAsset),
        expect: () => [
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.error),
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
          when(() => mockDeleteAsset.call(any()))
              .thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetAssets.call(any()))
              .thenAnswer((_) async => const SuccessState(data: []));
          return cubit;
        },
        act: (cubit) => cubit.deleteAsset(tId),
        expect: () => [
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loaded),
        ],
        verify: (_) {
          verify(() => mockDeleteAsset.call(tId)).called(1);
          verify(() => mockGetAssets.call(tUserProfile.companyId)).called(1);
        },
      );

      blocTest<AssetsCubit, AssetsState>(
        'should emit error and show failure toast when delete fails',
        build: () {
          when(() => mockDeleteAsset.call(any()))
              .thenAnswer((_) async => FailureState<bool>(message: 'Error'));
          return cubit;
        },
        act: (cubit) => cubit.deleteAsset(tId),
        expect: () => [
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.loading),
          isA<AssetsState>().having((s) => s.status, 'status', StateStatus.error),
        ],
        verify: (_) {
          verify(() => mockDeleteAsset.call(tId)).called(1);
          verifyNever(() => mockGetAssets.call(any()));
        },
      );
    });
  });
}
