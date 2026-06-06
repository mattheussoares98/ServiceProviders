import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/categories/domain/use_cases/get_categories_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetCategoriesUseCase useCase;
  late MockCategoriesRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoriesRepository();
    useCase = GetCategoriesUseCase(categoriesRepository: mockRepository);
    registerFallbackValue(TestFactory.makeCategoryEntity());
  });

  final tCategories = [
    TestFactory.makeCategoryEntity(),
    TestFactory.makeCategoryEntity(),
    TestFactory.makeCategoryEntity(),
  ];

  final workOrderId = faker.guid.guid();

  test(
    'should call repository.getCategory and return true on success',
    () async {
      // Arrange
      when(
        () => mockRepository.getCategories(any()),
      ).thenAnswer((_) async => SuccessState(data: tCategories));

      // Act
      final result = await useCase.call(workOrderId);

      // Assert
      expect(result.data, tCategories);
      expect(result, SuccessState(data: tCategories));
      verify(() => mockRepository.getCategories(workOrderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.getCategories(any())).thenAnswer(
      (_) async => FailureState<List<CategoryEntity>>(message: 'Create failed'),
    );

    // Act
    final result = await useCase(workOrderId);

    // Assert
    expect(result, isA<FailureState<List<CategoryEntity>>>());
    expect(result.message, 'Create failed');
    verify(() => mockRepository.getCategories(workOrderId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
