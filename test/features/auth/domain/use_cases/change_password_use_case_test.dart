import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late ChangePasswordUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = ChangePasswordUseCase(repository: mockAuthRepository);
  });

  final tNewPassword = faker.internet.password();

  test(
    'should call authRepository.changePassword and return SuccessState on success',
    () async {
      // Arrange
      when(
        () => mockAuthRepository.changePassword(any()),
      ).thenAnswer((_) async => SuccessState.nil);

      // Act
      final result = await useCase(tNewPassword);

      // Assert
      expect(result, isA<SuccessState<void>>());
      verify(() => mockAuthRepository.changePassword(tNewPassword)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test('should return a FailureState when the repository call fails', () async {
    // Arrange
    final tFailureState = FailureState<void>(
      message: 'Failed to update password',
    );
    when(
      () => mockAuthRepository.changePassword(any()),
    ).thenAnswer((_) async => tFailureState);

    // Act
    final result = await useCase(tNewPassword);

    // Assert
    expect(result, isA<FailureState<void>>());
    expect(result.message, 'Failed to update password');
    verify(() => mockAuthRepository.changePassword(tNewPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
