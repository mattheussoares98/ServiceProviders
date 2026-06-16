import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/assets/data/models/requests/asset_request_model.dart';
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
    registerFallbackValue(
      AssetRequestModel.fromEntity(EntityFactory.makeAssetEntity()),
    );
    registerFallbackValue(<AssetModel>[]);
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
        'should fetch assets from remote, cache them locally, and return list on success when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getAssets(any()),
          ).thenAnswer((_) async => SuccessState(data: [tAssetModel]));
          when(
            () => mockLocalDataSource.saveAssets(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.getAssets(tCompanyId);

          expect(result, isA<SuccessState<List<AssetEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tAssetEntity));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getAssets(tCompanyId)).called(1);
          verify(
            () => mockLocalDataSource.saveAssets([tAssetModel]),
          ).called(1);
          verifyNever(() => mockLocalDataSource.getAssets(any()));
        },
      );

      test(
        'should return failure when remote fetch succeeds but local cache fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getAssets(any()),
          ).thenAnswer((_) async => SuccessState(data: [tAssetModel]));
          when(
            () => mockLocalDataSource.saveAssets(any()),
          ).thenAnswer((_) async => FailureState(message: 'Cache error'));

          final result = await repository.getAssets(tCompanyId);

          expect(result, isA<FailureState<List<AssetEntity>>>());
          expect(result.message, 'Cache error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getAssets(tCompanyId)).called(1);
          verify(
            () => mockLocalDataSource.saveAssets([tAssetModel]),
          ).called(1);
        },
      );

      test(
        'should return failure when remote fetch fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getAssets(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          final result = await repository.getAssets(tCompanyId);

          expect(result, isA<FailureState<List<AssetEntity>>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getAssets(tCompanyId)).called(1);
          verifyNever(() => mockLocalDataSource.saveAssets(any()));
        },
      );

      test(
        'should return list of AssetEntity from local when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.getAssets(any()),
          ).thenAnswer((_) async => SuccessState(data: [tAssetModel]));

          final result = await repository.getAssets(tCompanyId);

          expect(result, isA<SuccessState<List<AssetEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tAssetEntity));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.getAssets(tCompanyId)).called(1);
          verifyNever(() => mockRemoteDataSource.getAssets(any()));
          verifyNever(() => mockLocalDataSource.saveAssets(any()));
        },
      );
    });

    group('getAssetById', () {
      test(
        'should fetch asset from remote, cache it locally, and return asset on success when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getAssetById(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssetModel));
          when(
            () => mockLocalDataSource.saveAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.getAssetById(tAssetEntity.id);

          expect(result, isA<SuccessState<AssetEntity>>());
          expect(result.data!.id, equals(tAssetEntity.id));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.getAssetById(tAssetEntity.id)).called(1);
          verify(() => mockLocalDataSource.saveAsset(tAssetModel)).called(1);
          verifyNever(() => mockLocalDataSource.getAssetById(any()));
        },
      );

      test(
        'should return asset from local when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.getAssetById(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssetModel));

          final result = await repository.getAssetById(tAssetEntity.id);

          expect(result, isA<SuccessState<AssetEntity>>());
          expect(result.data!.id, equals(tAssetEntity.id));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.getAssetById(tAssetEntity.id)).called(1);
          verifyNever(() => mockRemoteDataSource.getAssetById(any()));
          verifyNever(() => mockLocalDataSource.saveAsset(any()));
        },
      );
    });

    group('createAsset', () {
      test(
        'should save asset locally and return true when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.createAsset(tAssetEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.saveAsset(tAssetModel)).called(1);
          verifyNever(() => mockRemoteDataSource.createAsset(any()));
        },
      );

      test(
        'should create asset remotely, save locally, and return true when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createAsset(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssetModel));
          when(
            () => mockLocalDataSource.saveAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.createAsset(tAssetEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.createAsset(any())).called(1);
          verify(() => mockLocalDataSource.saveAsset(tAssetModel)).called(1);
        },
      );
    });

    group('updateAsset', () {
      test(
        'should save asset locally and return true when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.updateAsset(tAssetEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.saveAsset(tAssetModel)).called(1);
          verifyNever(() => mockRemoteDataSource.updateAsset(any()));
        },
      );

      test(
        'should update asset remotely, save locally, and return true when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateAsset(any()),
          ).thenAnswer((_) async => SuccessState(data: tAssetModel));
          when(
            () => mockLocalDataSource.saveAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.updateAsset(tAssetEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.updateAsset(any())).called(1);
          verify(() => mockLocalDataSource.saveAsset(tAssetModel)).called(1);
        },
      );
    });

    group('deleteAsset', () {
      test(
        'should delete asset locally and return true when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.deleteAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.deleteAsset(tAssetEntity.id);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.deleteAsset(tAssetEntity.id)).called(1);
          verifyNever(() => mockRemoteDataSource.deleteAsset(any()));
        },
      );

      test(
        'should delete asset remotely, delete locally, and return true when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteAsset(any()),
          ).thenAnswer((_) async => SuccessState.nil);
          when(
            () => mockLocalDataSource.deleteAsset(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.deleteAsset(tAssetEntity.id);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.deleteAsset(tAssetEntity.id)).called(1);
          verify(() => mockLocalDataSource.deleteAsset(tAssetEntity.id)).called(1);
        },
      );
    });
  });
}
