import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/update_asset_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late UpdateAssetUseCase useCase;
  late MockAssetsRepository mockRepository;

  setUp(() {
    mockRepository = MockAssetsRepository();
    useCase = UpdateAssetUseCase(assetsRepository: mockRepository);
    registerFallbackValue(TestFactory.makeAssetEntity());
  });

  final tAsset = TestFactory.makeAssetEntity();

  test(
    'should call repository.updateAsset and return true on success',
    () async {
      // Arrange
      when(
        () => mockRepository.updateAsset(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await useCase(tAsset);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.updateAsset(tAsset)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(
      () => mockRepository.updateAsset(any()),
    ).thenAnswer((_) async => FailureState<bool>(message: 'Update failed'));

    // Act
    final result = await useCase(tAsset);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Update failed');
    verify(() => mockRepository.updateAsset(tAsset)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
