import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/categories/domain/use_cases/update_category_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late UpdateCategoryUseCase useCase;
  late MockCategoriesRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoriesRepository();
    useCase = UpdateCategoryUseCase(categoriesRepository: mockRepository);
    registerFallbackValue(TestFactory.makeCategoryEntity());
  });

  final tCategory = TestFactory.makeCategoryEntity();

  test(
    'should call repository.updateCategory and return true on success',
    () async {
      // Arrange
      when(
        () => mockRepository.updateCategory(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await useCase(tCategory);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.updateCategory(tCategory)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(
      () => mockRepository.updateCategory(any()),
    ).thenAnswer((_) async => FailureState<bool>(message: 'Update failed'));

    // Act
    final result = await useCase(tCategory);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Update failed');
    verify(() => mockRepository.updateCategory(tCategory)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
