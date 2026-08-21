import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/create_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/delete_asset_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_asset_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_assets_by_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/update_asset_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockAssetsRepository mockRepository;

  // Use cases
  late CreateAssetUseCase createAssetUseCase;
  late UpdateAssetUseCase updateAssetUseCase;
  late DeleteAssetUseCase deleteAssetUseCase;
  late GetAssetsUseCase getAssetsUseCase;
  late GetAssetsByIdsUseCase getAssetsByIdsUseCase;
  late GetAssetByIdUseCase getAssetByIdUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeAssetEntity());
  });

  setUp(() {
    mockRepository = MockAssetsRepository();
    createAssetUseCase = CreateAssetUseCase(assetsRepository: mockRepository);
    updateAssetUseCase = UpdateAssetUseCase(assetsRepository: mockRepository);
    deleteAssetUseCase = DeleteAssetUseCase(assetsRepository: mockRepository);
    getAssetsUseCase = GetAssetsUseCase(assetsRepository: mockRepository);
    getAssetsByIdsUseCase = GetAssetsByIdsUseCase(
      assetsRepository: mockRepository,
    );
    getAssetByIdUseCase = GetAssetByIdUseCase(assetsRepository: mockRepository);
  });

  final tAssetEntity = EntityFactory.makeAssetEntity();
  final tAssetList = EntityFactory.makeAssetEntityList();
  final tId = faker.guid.guid();

  group('Assets Use Cases', () {
    group('CreateAssetUseCase', () {
      test(
        'should call repository.createAsset and return SuccessState',
        () async {
          // Arrange
          when(
            () => mockRepository.createAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await createAssetUseCase(tAssetEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.createAsset(tAssetEntity)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.createAsset(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        // Act
        final result = await createAssetUseCase(tAssetEntity);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.createAsset(tAssetEntity)).called(1);
      });
    });

    group('UpdateAssetUseCase', () {
      test(
        'should call repository.updateAsset and return SuccessState',
        () async {
          // Arrange
          when(
            () => mockRepository.updateAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await updateAssetUseCase(tAssetEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.updateAsset(tAssetEntity)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.updateAsset(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        // Act
        final result = await updateAssetUseCase(tAssetEntity);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.updateAsset(tAssetEntity)).called(1);
      });
    });

    group('DeleteAssetUseCase', () {
      test(
        'should call repository.deleteAsset and return SuccessState',
        () async {
          // Arrange
          when(
            () => mockRepository.deleteAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await deleteAssetUseCase(tId);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.deleteAsset(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.deleteAsset(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        // Act
        final result = await deleteAssetUseCase(tId);

        // Assert
        expect(result, isA<FailureState<bool>>());
        verify(() => mockRepository.deleteAsset(tId)).called(1);
      });
    });

    group('GetAssetsUseCase', () {
      test(
        'should call repository.getAssets and return list of assets',
        () async {
          // Arrange
          when(
            () => mockRepository.getAssets(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssetList));

          // Act
          final result = await getAssetsUseCase(tId);

          // Assert
          expect(result, isA<SuccessState<List<AssetEntity>>>());
          expect(result.data, tAssetList);
          verify(() => mockRepository.getAssets(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getAssets(any())).thenAnswer(
          (_) async => FailureState<List<AssetEntity>>(message: 'Error'),
        );

        // Act
        final result = await getAssetsUseCase(tId);

        // Assert
        expect(result, isA<FailureState<List<AssetEntity>>>());
        verify(() => mockRepository.getAssets(tId)).called(1);
      });
    });

    group('GetAssetsByIdsUseCase', () {
      test(
        'should call repository.getAssetsByIds and return list of assets',
        () async {
          // Arrange
          when(
            () => mockRepository.getAssetsByIds(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssetList));

          // Act
          final result = await getAssetsByIdsUseCase([tId]);

          // Assert
          expect(result, isA<SuccessState<List<AssetEntity>>>());
          expect(result.data, tAssetList);
          verify(() => mockRepository.getAssetsByIds([tId])).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getAssetsByIds(any())).thenAnswer(
          (_) async => FailureState<List<AssetEntity>>(message: 'Error'),
        );

        // Act
        final result = await getAssetsByIdsUseCase([tId]);

        // Assert
        expect(result, isA<FailureState<List<AssetEntity>>>());
        verify(() => mockRepository.getAssetsByIds([tId])).called(1);
      });
    });

    group('GetAssetByIdUseCase', () {
      test(
        'should call repository.getAssetById and return AssetEntity',
        () async {
          // Arrange
          when(
            () => mockRepository.getAssetById(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssetEntity));

          // Act
          final result = await getAssetByIdUseCase(tId);

          // Assert
          expect(result, isA<SuccessState<AssetEntity>>());
          expect(result.data, tAssetEntity);
          verify(() => mockRepository.getAssetById(tId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(
          () => mockRepository.getAssetById(any()),
        ).thenAnswer((_) async => FailureState<AssetEntity>(message: 'Error'));

        // Act
        final result = await getAssetByIdUseCase(tId);

        // Assert
        expect(result, isA<FailureState<AssetEntity>>());
        verify(() => mockRepository.getAssetById(tId)).called(1);
      });
    });
  });
}
