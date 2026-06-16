import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/assets/data/models/responses/asset_model.dart';
import 'package:clean_architecture/features/assets/data/repositories/assets_repository_impl.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockAssetsRemoteDataSource mockRemoteDataSource;
  late MockAssetsLocalDataSource mockLocalDataSource;
  late AssetsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      AssetModel.fromEntity(EntityFactory.makeAssetEntity()),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockAssetsRemoteDataSource();
    mockLocalDataSource = MockAssetsLocalDataSource();
    repository = AssetsRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tAssetEntity = EntityFactory.makeAssetEntity();
  final tAssetModel = AssetModel.fromEntity(tAssetEntity);
  final tCompanyId = faker.guid.guid();

  group('AssetsRepositoryImpl', () {
    group('getAssets', () {
      test(
        'should return list of AssetEntity on success from local data source',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getAssets(any()),
          ).thenAnswer((_) async => SuccessState(data: [tAssetModel]));

          // Act
          final result = await repository.getAssets(tCompanyId);

          // Assert
          expect(result, isA<SuccessState<List<AssetEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tAssetModel.id);
          verify(() => mockLocalDataSource.getAssets(tCompanyId)).called(1);
        },
      );

      test('should return FailureState when local data source fails', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getAssets(any()),
        ).thenAnswer((_) async => FailureState(message: 'Database error'));

        // Act
        final result = await repository.getAssets(tCompanyId);

        // Assert
        expect(result, isA<FailureState<List<AssetEntity>>>());
        expect(result.message, 'Database error');
      });
    });

    group('getAssetById', () {
      test(
        'should return AssetEntity on success from local data source',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getAssetById(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssetModel));

          // Act
          final result = await repository.getAssetById(tAssetEntity.id);

          // Assert
          expect(result, isA<SuccessState<AssetEntity>>());
          expect(result.data!.id, tAssetModel.id);
          verify(
            () => mockLocalDataSource.getAssetById(tAssetEntity.id),
          ).called(1);
        },
      );

      test('should return FailureState when local data source fails', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getAssetById(any()),
        ).thenAnswer((_) async => FailureState(message: 'Database error'));

        // Act
        final result = await repository.getAssetById(tAssetEntity.id);

        // Assert
        expect(result, isA<FailureState<AssetEntity>>());
        expect(result.message, 'Database error');
      });
    });

    group('createAsset', () {
      test(
        'should return true when asset is saved successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createAsset(tAssetEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveAsset(tAssetModel)).called(1);
        },
      );
    });

    group('updateAsset', () {
      test(
        'should return true when asset is updated successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.updateAsset(tAssetEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveAsset(tAssetModel)).called(1);
        },
      );
    });

    group('deleteAsset', () {
      test(
        'should return true when asset is deleted successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.deleteAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.deleteAsset(tAssetEntity.id);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.deleteAsset(tAssetEntity.id),
          ).called(1);
        },
      );
    });
  });
}
