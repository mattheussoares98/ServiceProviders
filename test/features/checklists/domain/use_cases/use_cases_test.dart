import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:clean_architecture/features/checklists/domain/use_cases/get_checklists_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetChecklistsUseCase useCase;
  late MockChecklistsRepository mockRepository;

  setUp(() {
    mockRepository = MockChecklistsRepository();
    useCase = GetChecklistsUseCase(checklistsRepository: mockRepository);
    registerFallbackValue(TestFactory.makeChecklistTemplateEntity());
  });

  final tTemplates = [
    TestFactory.makeChecklistTemplateEntity(),
    TestFactory.makeChecklistTemplateEntity(),
    TestFactory.makeChecklistTemplateEntity(),
  ];

  final workOrderId = faker.guid.guid();

  group('GetChecklistsUseCase', () {
    test(
      'should call repository.getTemplates and return true on success',
      () async {
        // Arrange
        when(
          () => mockRepository.getTemplates(any()),
        ).thenAnswer((_) async => SuccessState(data: tTemplates));

        // Act
        final result = await useCase.call(workOrderId);

        // Assert
        expect(result.data, tTemplates);
        expect(result, SuccessState(data: tTemplates));
        verify(() => mockRepository.getTemplates(workOrderId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return FailureState when repository fails', () async {
      // Arrange
      when(() => mockRepository.getTemplates(any())).thenAnswer(
        (_) async => FailureState<List<ChecklistTemplateEntity>>(
          message: 'Create failed',
        ),
      );

      // Act
      final result = await useCase(workOrderId);

      // Assert
      expect(result, isA<FailureState<List<ChecklistTemplateEntity>>>());
      expect(result.message, 'Create failed');
      verify(() => mockRepository.getTemplates(workOrderId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
