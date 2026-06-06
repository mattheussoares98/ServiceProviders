import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late DeleteCategoryUseCase useCase;
  late MockCategoriesRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoriesRepository();
    useCase = DeleteCategoryUseCase(categoriesRepository: mockRepository);
    registerFallbackValue(TestFactory.makeCategoryEntity());
  });

  final tCategoryId = TestFactory.makeCategoryEntity().id;

  test(
    'should call repository.deleteCategory and return true on success',
    () async {
      // Arrange
      when(
        () => mockRepository.deleteCategory(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await useCase.call(tCategoryId);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.deleteCategory(tCategoryId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(
      () => mockRepository.deleteCategory(any()),
    ).thenAnswer((_) async => FailureState<bool>(message: 'Delete failed'));

    // Act
    final result = await useCase(tCategoryId);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Delete failed');
    verify(() => mockRepository.deleteCategory(tCategoryId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
