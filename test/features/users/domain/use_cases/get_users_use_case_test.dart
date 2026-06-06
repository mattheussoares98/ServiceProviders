import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_users_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late GetUsersUseCase useCase;
  late MockUsersRepository mockRepository;

  setUp(() {
    mockRepository = MockUsersRepository();
    useCase = GetUsersUseCase(usersRepository: mockRepository);
  });

  final tCompanyId = TestFactory.makeUserProfileEntity().companyId;
  final tUsers = TestFactory.makeUserProfileEntityList();

  test('should return a list of user profiles on success', () async {
    // Arrange
    when(() => mockRepository.getUserProfiles(any()))
        .thenAnswer((_) async => SuccessState(data: tUsers));

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<SuccessState<List<UserProfileEntity>>>());
    expect(result.data, tUsers);
    verify(() => mockRepository.getUserProfiles(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return FailureState when repository fails', () async {
    // Arrange
    when(() => mockRepository.getUserProfiles(any())).thenAnswer(
      (_) async =>
          FailureState<List<UserProfileEntity>>(message: 'Load failed'),
    );

    // Act
    final result = await useCase(tCompanyId);

    // Assert
    expect(result, isA<FailureState<List<UserProfileEntity>>>());
    expect(result.message, 'Load failed');
    verify(() => mockRepository.getUserProfiles(tCompanyId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
