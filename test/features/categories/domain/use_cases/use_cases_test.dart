import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/categories/domain/use_cases/create_category_use_case.dart';
import 'package:clean_architecture/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:clean_architecture/features/categories/domain/use_cases/get_categories_use_case.dart';
import 'package:clean_architecture/features/categories/domain/use_cases/update_category_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockCategoriesRepository mockRepository;

  // Use cases
  late CreateCategoryUseCase createCategoryUseCase;
  late UpdateCategoryUseCase updateCategoryUseCase;
  late DeleteCategoryUseCase deleteCategoryUseCase;
  late GetCategoriesUseCase getCategoriesUseCase;

  setUpAll(() {
    registerFallbackValue(TestFactory.makeCategoryEntity());
  });

  setUp(() {
    mockRepository = MockCategoriesRepository();
    createCategoryUseCase = CreateCategoryUseCase(categoriesRepository: mockRepository);
    updateCategoryUseCase = UpdateCategoryUseCase(categoriesRepository: mockRepository);
    deleteCategoryUseCase = DeleteCategoryUseCase(categoriesRepository: mockRepository);
    getCategoriesUseCase = GetCategoriesUseCase(categoriesRepository: mockRepository);
  });

  final tCategory = TestFactory.makeCategoryEntity();
  final tCategories = [
    TestFactory.makeCategoryEntity(),
    TestFactory.makeCategoryEntity(),
    TestFactory.makeCategoryEntity(),
  ];
  final tCompanyId = faker.guid.guid();
  final tId = faker.guid.guid();

  group('Categories Use Cases', () {
    group('CreateCategoryUseCase', () {
      test('should call repository.createCategory and return true on success', () async {
        // Arrange
        when(() => mockRepository.createCategory(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await createCategoryUseCase(tCategory);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRepository.createCategory(tCategory)).called(1);
      });

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.createCategory(any()))
            .thenAnswer((_) async => FailureState<bool>(message: 'Create failed'));

        // Act
        final result = await createCategoryUseCase(tCategory);

        // Assert
        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Create failed');
        verify(() => mockRepository.createCategory(tCategory)).called(1);
      });
    });

    group('UpdateCategoryUseCase', () {
      test('should call repository.updateCategory and return true on success', () async {
        // Arrange
        when(() => mockRepository.updateCategory(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await updateCategoryUseCase(tCategory);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRepository.updateCategory(tCategory)).called(1);
      });

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.updateCategory(any()))
            .thenAnswer((_) async => FailureState<bool>(message: 'Update failed'));

        // Act
        final result = await updateCategoryUseCase(tCategory);

        // Assert
        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Update failed');
        verify(() => mockRepository.updateCategory(tCategory)).called(1);
      });
    });

    group('DeleteCategoryUseCase', () {
      test('should call repository.deleteCategory and return true on success', () async {
        // Arrange
        when(() => mockRepository.deleteCategory(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await deleteCategoryUseCase(tId);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRepository.deleteCategory(tId)).called(1);
      });

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.deleteCategory(any()))
            .thenAnswer((_) async => FailureState<bool>(message: 'Delete failed'));

        // Act
        final result = await deleteCategoryUseCase(tId);

        // Assert
        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Delete failed');
        verify(() => mockRepository.deleteCategory(tId)).called(1);
      });
    });

    group('GetCategoriesUseCase', () {
      test('should call repository.getCategories and return list of categories on success', () async {
        // Arrange
        when(() => mockRepository.getCategories(any()))
            .thenAnswer((_) async => SuccessState(data: tCategories));

        // Act
        final result = await getCategoriesUseCase(tCompanyId);

        // Assert
        expect(result, isA<SuccessState<List<CategoryEntity>>>());
        expect(result.data, tCategories);
        verify(() => mockRepository.getCategories(tCompanyId)).called(1);
      });

      test('should return FailureState when repository fails', () async {
        // Arrange
        when(() => mockRepository.getCategories(any()))
            .thenAnswer((_) async => FailureState<List<CategoryEntity>>(message: 'Load failed'));

        // Act
        final result = await getCategoriesUseCase(tCompanyId);

        // Assert
        expect(result, isA<FailureState<List<CategoryEntity>>>());
        expect(result.message, 'Load failed');
        verify(() => mockRepository.getCategories(tCompanyId)).called(1);
      });
    });
  });
}
