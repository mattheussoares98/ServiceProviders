import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/create_asset_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late CreateAssetUseCase useCase;
  late MockAssetsRepository mockRepository;

  setUp(() {
    mockRepository = MockAssetsRepository();
    useCase = CreateAssetUseCase(assetsRepository: mockRepository);
    registerFallbackValue(TestFactory.makeAssetEntity());
  });

  final tAsset = TestFactory.makeAssetEntity();

  test(
    'should call repository.createAsset and return true on success',
    () async {
      // Arrange
      when(
        () => mockRepository.createAsset(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      // Act
      final result = await useCase(tAsset);

      // Assert
      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(() => mockRepository.createAsset(tAsset)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(
      () => mockRepository.createAsset(any()),
    ).thenAnswer((_) async => FailureState<bool>(message: 'Create failed'));

    // Act
    final result = await useCase(tAsset);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Create failed');
    verify(() => mockRepository.createAsset(tAsset)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
