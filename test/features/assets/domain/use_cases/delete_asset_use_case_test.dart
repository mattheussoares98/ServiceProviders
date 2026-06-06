import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/delete_asset_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late DeleteAssetUseCase useCase;
  late MockAssetsRepository mockRepository;

  setUp(() {
    mockRepository = MockAssetsRepository();
    useCase = DeleteAssetUseCase(assetsRepository: mockRepository);
  });

  final tAssetId = faker.guid.guid();

  test('should call repository.deleteAsset and return true on success',
      () async {
    // Arrange
    when(() => mockRepository.deleteAsset(any()))
        .thenAnswer((_) async => const SuccessState(data: true));

    // Act
    final result = await useCase(tAssetId);

    // Assert
    expect(result, isA<SuccessState<bool>>());
    expect(result.data, true);
    verify(() => mockRepository.deleteAsset(tAssetId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.deleteAsset(any())).thenAnswer(
      (_) async => FailureState<bool>(message: 'Delete failed'),
    );

    // Act
    final result = await useCase(tAssetId);

    // Assert
    expect(result, isA<FailureState<bool>>());
    expect(result.message, 'Delete failed');
    verify(() => mockRepository.deleteAsset(tAssetId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
