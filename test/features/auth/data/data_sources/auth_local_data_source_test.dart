import 'package:clean_architecture/core/data/models/responses/user_model.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockLocalStorageClient mockLocalDatabase;
  late AuthLocalDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(const UserDataEntity.empty());
  });

  setUp(() {
    mockLocalDatabase = MockLocalStorageClient();
    dataSource = AuthLocalDataSourceImpl(localDatabase: mockLocalDatabase);
  });

  final userModel = UserModel.fromEntity(EntityFactory.makeUserEntity());

  final tUserDataModel = UserDataResponseModel(
    user: userModel,
    accessToken: 'access',
    refreshToken: 'refresh',
  );

  group('saveUserData', () {
    test(
      'should return SuccessState(true) when data is saved successfully',
      () async {
        // Arrange
        when(
          () => mockLocalDatabase.saveUserSession(any()),
        ).thenAnswer((_) async {});

        // Act
        final result = await dataSource.saveUserData(tUserDataModel);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockLocalDatabase.saveUserSession(tUserDataModel.toEntity()),
        ).called(1);
      },
    );

    test(
      'should return FailureState when saving throws an exception',
      () async {
        // Arrange
        final exception = Exception('Failed to save');
        when(
          () => mockLocalDatabase.saveUserSession(any()),
        ).thenThrow(exception);

        // Act
        final result = await dataSource.saveUserData(tUserDataModel);

        // Assert
        expect(result, isA<FailureState<bool>>());
      },
    );
  });

  group('getUserData', () {
    test(
      'should return SuccessState with UserDataModel when data is found',
      () async {
        // Arrange
        when(
          () => mockLocalDatabase.getUserSession(),
        ).thenReturn(tUserDataModel.toEntity());

        // Act
        final result = await dataSource.getUserData();

        // Assert
        expect(result, isA<SuccessState<UserDataResponseModel>>());
        expect(result.data, isNotNull);
        expect(result.data!.user.id, userModel.id);
        expect(result.data!.accessToken, 'access');
        verify(() => mockLocalDatabase.getUserSession()).called(1);
      },
    );

    test('should return FailureState when no data is found (null)', () async {
      // Arrange
      when(
        () => mockLocalDatabase.getUserSession(),
      ).thenReturn(null);

      // Act
      final result = await dataSource.getUserData();

      // Assert
      expect(result, isA<FailureState<UserDataResponseModel>>());
      verify(() => mockLocalDatabase.getUserSession()).called(1);
    });

    test(
      'should return FailureState when getting data throws an exception',
      () async {
        // Arrange
        final exception = Exception('Failed to read');
        when(
          () => mockLocalDatabase.getUserSession(),
        ).thenThrow(exception);

        // Act
        final result = await dataSource.getUserData();

        // Assert
        expect(result, isA<FailureState<UserDataResponseModel>>());
      },
    );
  });
}
