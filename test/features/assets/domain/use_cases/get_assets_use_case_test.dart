import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/use_cases/get_assets_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetAssetsUseCase useCase;
  late MockAssetsRepository mockRepository;

  setUp(() {
    mockRepository = MockAssetsRepository();
    useCase = GetAssetsUseCase(assetsRepository: mockRepository);
  });

  final tCompanyId = TestFactory.makeAssetEntity().companyId;
  final tAssets = TestFactory.makeAssetEntityList();

  test('should return a list of assets on success', () async {
    // Arrange
    when(() => mockRepository.getAssets(any()))
        .thenAnswer((_) async => SuccessState(data: tAssets));

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<SuccessState<List<AssetEntity>>>());
    expect(result.data, tAssets);
    verify(() => mockRepository.getAssets(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.getAssets(any())).thenAnswer(
      (_) async =>
          FailureState<List<AssetEntity>>(message: 'Load failed'),
    );

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<FailureState<List<AssetEntity>>>());
    expect(result.message, 'Load failed');
    verify(() => mockRepository.getAssets(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
