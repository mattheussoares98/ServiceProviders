import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/locations/domain/use_cases/get_locations_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetLocationsUseCase useCase;
  late MockLocationsRepository mockRepository;

  setUp(() {
    mockRepository = MockLocationsRepository();
    useCase = GetLocationsUseCase(locationsRepository: mockRepository);
  });

  final tCompanyId = TestFactory.makeLocationEntity().companyId;
  final tLocations = TestFactory.makeLocationEntityList();

  test('should return a list of locations on success', () async {
    // Arrange
    when(() => mockRepository.getLocations(any()))
        .thenAnswer((_) async => SuccessState(data: tLocations));

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<SuccessState<List<LocationEntity>>>());
    expect(result.data, tLocations);
    verify(() => mockRepository.getLocations(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.getLocations(any())).thenAnswer(
      (_) async =>
          FailureState<List<LocationEntity>>(message: 'Load failed'),
    );

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<FailureState<List<LocationEntity>>>());
    expect(result.message, 'Load failed');
    verify(() => mockRepository.getLocations(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
