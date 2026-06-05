import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/login_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(authRepository: mockAuthRepository);
    registerFallbackValue(const AuthenticationEntity(email: '', password: ''));
  });

  final tAuthentication = TestFactory.makeAuthentication().copyWith(
    username: 'test',
    password: 'password',
  );
  final tUserData = TestFactory.makeUserDataEntity().copyWith(
    user: TestFactory.makeUserEntity(),
  );

  test(
    'should call authRepository.login and return user data on success',
    () async {
      // Arrange
      when(
        () => mockAuthRepository.login(any()),
      ).thenAnswer((_) async => SuccessState(data: tUserData));

      // Act
      final result = await useCase(tAuthentication);

      // Assert
      expect(result, isA<SuccessState<UserDataEntity>>());
      expect(result.data, tUserData);
      verify(() => mockAuthRepository.login(tAuthentication)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test('should return a FailureState when the repository call fails', () async {
    // Arrange
    final tFailureState = FailureState<UserDataEntity>(message: 'Login Failed');
    when(
      () => mockAuthRepository.login(any()),
    ).thenAnswer((_) async => tFailureState);

    // Act
    final result = await useCase(tAuthentication);

    // Assert
    expect(result, isA<FailureState<UserDataEntity>>());
    expect(result.message, 'Login Failed');
    verify(() => mockAuthRepository.login(tAuthentication)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
