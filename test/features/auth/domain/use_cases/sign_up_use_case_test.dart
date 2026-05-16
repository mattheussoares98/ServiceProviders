import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user.dart';
import 'package:clean_architecture/core/domain/entities/user_data.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late SignUpUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(
      const SignUpEntity(name: '', email: '', password: ''),
    );
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignUpUseCase(authRepository: mockAuthRepository);
  });

  final tSignUpEntity = SignUpEntity(
    name: faker.person.name(),
    email: faker.internet.email(),
    password: faker.internet.password(),
  );

  final tUser = User(
    id: faker.guid.guid(),
    firstName: faker.person.firstName(),
    lastName: faker.person.lastName(),
    username: faker.internet.userName(),
    email: faker.internet.email(),
    isActive: true,
  );

  final tUserData = UserDataEntity(
    user: tUser,
    accessToken: faker.jwt.valid(),
    refreshToken: faker.jwt.valid(),
  );

  test(
    'should call authRepository.signUp and return user data on success',
    () async {
      // Arrange
      when(
        () => mockAuthRepository.signUp(any()),
      ).thenAnswer((_) async => SuccessState(data: tUserData));

      // Act
      final result = await useCase(tSignUpEntity);

      // Assert
      expect(result, isA<SuccessState<UserDataEntity>>());
      expect(result.data, tUserData);
      verify(() => mockAuthRepository.signUp(tSignUpEntity)).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test('should return a FailureState when the repository call fails', () async {
    // Arrange
    final tErrorMessage = faker.lorem.sentence();
    final tFailureState = FailureState<UserDataEntity>(message: tErrorMessage);
    when(
      () => mockAuthRepository.signUp(any()),
    ).thenAnswer((_) async => tFailureState);

    // Act
    final result = await useCase(tSignUpEntity);

    // Assert
    expect(result, isA<FailureState<UserDataEntity>>());
    expect(result.message, tErrorMessage);
    verify(() => mockAuthRepository.signUp(tSignUpEntity)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
