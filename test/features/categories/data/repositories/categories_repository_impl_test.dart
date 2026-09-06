import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/requests/category_request_model.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/responses/category_model.dart';
import 'package:o_jogo_da_obra/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/asset_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockCategoriesRemoteDataSource mockRemoteDataSource;
  late MockCategoriesLocalDataSource mockLocalDataSource;
  late CategoriesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      CategoryModel.fromEntity(AssetFactory.makeCategoryEntity()),
    );
    registerFallbackValue(
      CategoryRequestModel.fromEntity(AssetFactory.makeCategoryEntity()),
    );
    registerFallbackValue(<CategoryModel>[]);
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockCategoriesRemoteDataSource();
    mockLocalDataSource = MockCategoriesLocalDataSource();
    repository = CategoriesRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tEntity = AssetFactory.makeCategoryEntity();
  final tModel = CategoryModel.fromEntity(tEntity);
  final tCompanyId = faker.guid.guid();

  group('CategoriesRepositoryImpl', () {
    group('getCategories', () {
      test(
        'should fetch categories from remote, cache them locally, and return list on success when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getCategories(any()),
          ).thenAnswer((_) async => SuccessState(data: [tModel]));
          when(
            () => mockLocalDataSource.saveCategories(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.getCategories(tCompanyId);

          expect(result, isA<SuccessState<List<CategoryEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tEntity));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.getCategories(tCompanyId),
          ).called(1);
          verify(() => mockLocalDataSource.saveCategories([tModel])).called(1);
          verifyNever(() => mockLocalDataSource.getCategories(any()));
        },
      );

      test(
        'should return failure when remote fetch succeeds but local cache fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getCategories(any()),
          ).thenAnswer((_) async => SuccessState(data: [tModel]));
          when(
            () => mockLocalDataSource.saveCategories(any()),
          ).thenAnswer((_) async => FailureState(message: 'Cache error'));

          final result = await repository.getCategories(tCompanyId);

          expect(result, isA<FailureState<List<CategoryEntity>>>());
          expect(result.message, 'Cache error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.getCategories(tCompanyId),
          ).called(1);
          verify(() => mockLocalDataSource.saveCategories([tModel])).called(1);
        },
      );

      test(
        'should return failure when remote fetch fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getCategories(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          final result = await repository.getCategories(tCompanyId);

          expect(result, isA<FailureState<List<CategoryEntity>>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.getCategories(tCompanyId),
          ).called(1);
          verifyNever(() => mockLocalDataSource.saveCategories(any()));
        },
      );

      test(
        'should return list of CategoryEntity from local when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.getCategories(any()),
          ).thenAnswer((_) async => SuccessState(data: [tModel]));

          final result = await repository.getCategories(tCompanyId);

          expect(result, isA<SuccessState<List<CategoryEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tEntity));
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.getCategories(tCompanyId)).called(1);
          verifyNever(() => mockRemoteDataSource.getCategories(any()));
          verifyNever(() => mockLocalDataSource.saveCategories(any()));
        },
      );

      test(
        'should return failure when local fetch fails when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.getCategories(any()),
          ).thenAnswer((_) async => FailureState(message: 'Database error'));

          final result = await repository.getCategories(tCompanyId);

          expect(result, isA<FailureState<List<CategoryEntity>>>());
          expect(result.message, 'Database error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.getCategories(tCompanyId)).called(1);
          verifyNever(() => mockRemoteDataSource.getCategories(any()));
        },
      );
    });

    group('createCategory', () {
      test(
        'should save category locally and return true when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveCategory(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.createCategory(tEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.saveCategory(tModel)).called(1);
          verifyNever(() => mockRemoteDataSource.createCategory(any()));
        },
      );

      test(
        'should create category remotely, save locally, and return true when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createCategory(any()),
          ).thenAnswer((_) async => SuccessState(data: tModel));
          when(
            () => mockLocalDataSource.saveCategory(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.createCategory(tEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.createCategory(any())).called(1);
          verify(() => mockLocalDataSource.saveCategory(tModel)).called(1);
        },
      );

      test(
        'should return FailureState when remote creation fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createCategory(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          final result = await repository.createCategory(tEntity);

          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.createCategory(any())).called(1);
          verifyNever(() => mockLocalDataSource.saveCategory(any()));
        },
      );
    });

    group('updateCategory', () {
      test(
        'should save category locally and return true when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveCategory(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.updateCategory(tEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockLocalDataSource.saveCategory(tModel)).called(1);
          verifyNever(() => mockRemoteDataSource.updateCategory(any()));
        },
      );

      test(
        'should update category remotely, save locally, and return true when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateCategory(any()),
          ).thenAnswer((_) async => SuccessState(data: tModel));
          when(
            () => mockLocalDataSource.saveCategory(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.updateCategory(tEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.updateCategory(any())).called(1);
          verify(() => mockLocalDataSource.saveCategory(tModel)).called(1);
        },
      );

      test(
        'should return FailureState when remote update fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateCategory(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          final result = await repository.updateCategory(tEntity);

          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.updateCategory(any())).called(1);
          verifyNever(() => mockLocalDataSource.saveCategory(any()));
        },
      );
    });

    group('deleteCategory', () {
      test(
        'should delete category locally and return true when offline',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.deleteCategory(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.deleteCategory(tEntity.id);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockLocalDataSource.deleteCategory(tEntity.id),
          ).called(1);
          verifyNever(() => mockRemoteDataSource.deleteCategory(any()));
        },
      );

      test(
        'should delete category remotely, delete locally, and return true when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteCategory(any()),
          ).thenAnswer((_) async => SuccessState.nil);
          when(
            () => mockLocalDataSource.deleteCategory(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.deleteCategory(tEntity.id);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.deleteCategory(tEntity.id),
          ).called(1);
          verify(
            () => mockLocalDataSource.deleteCategory(tEntity.id),
          ).called(1);
        },
      );

      test(
        'should return FailureState when remote deletion fails when online',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.deleteCategory(any()),
          ).thenAnswer((_) async => FailureState(message: 'Server error'));

          final result = await repository.deleteCategory(tEntity.id);

          expect(result, isA<FailureState<bool>>());
          expect(result.message, 'Server error');
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.deleteCategory(tEntity.id),
          ).called(1);
          verifyNever(() => mockLocalDataSource.deleteCategory(any()));
        },
      );
    });
  });
}
