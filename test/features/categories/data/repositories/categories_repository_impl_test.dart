import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/categories/data/models/responses/category_response_model.dart';
import 'package:clean_architecture/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockCategoriesRemoteDataSource mockRemoteDataSource;
  late MockCategoriesLocalDataSource mockLocalDataSource;
  late CategoriesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      CategoryResponseModel.fromEntity(EntityFactory.makeCategoryEntity()),
    );
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

  final tEntity = EntityFactory.makeCategoryEntity();
  final tModel = CategoryResponseModel.fromEntity(tEntity);
  final tCompanyId = faker.guid.guid();

  group('CategoriesRepositoryImpl', () {
    group('getCategories', () {
      test(
        'should return list of CategoryEntity on success from local data source',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getCategories(any()),
          ).thenAnswer((_) async => SuccessState(data: [tModel]));

          // Act
          final result = await repository.getCategories(tCompanyId);

          // Assert
          expect(result, isA<SuccessState<List<CategoryEntity>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tEntity));
          verify(() => mockLocalDataSource.getCategories(tCompanyId)).called(1);
        },
      );

      test('should return FailureState when local data source fails', () async {
        // Arrange
        when(
          () => mockLocalDataSource.getCategories(any()),
        ).thenAnswer((_) async => FailureState(message: 'Database error'));

        // Act
        final result = await repository.getCategories(tCompanyId);

        // Assert
        expect(result, isA<FailureState<List<CategoryEntity>>>());
        expect(result.message, 'Database error');
      });
    });

    group('createCategory', () {
      test(
        'should return true when category is saved successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveCategory(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.createCategory(tEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveCategory(tModel)).called(1);
        },
      );
    });

    group('updateCategory', () {
      test(
        'should return true when category is updated successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveCategory(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.updateCategory(tEntity);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveCategory(tModel)).called(1);
        },
      );
    });

    group('deleteCategory', () {
      test(
        'should return true when category is deleted successfully locally',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.deleteCategory(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.deleteCategory(tEntity.id);

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.deleteCategory(tEntity.id),
          ).called(1);
        },
      );
    });
  });
}
