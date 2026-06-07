import 'package:clean_architecture/core/data/models/responses/user_model.dart';
import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/features/auth/data/data_sources/session_local_data_source.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockLocalStorageClient mockLocalStorageClient;
  late SessionLocalDataSourceImpl sessionLocalDataSource;

  setUpAll(() {
    registerFallbackValue(const UserDataEntity.empty());
  });

  setUp(() {
    mockLocalStorageClient = MockLocalStorageClient();
    sessionLocalDataSource = SessionLocalDataSourceImpl(mockLocalStorageClient);
  });

  final userDataResponse = UserDataResponseModel(
    user: UserModel.fromEntity(EntityFactory.makeUserEntity()),
    accessToken: 'access_token',
    refreshToken: 'refresh_token',
  );

  group('SessionLocalDataSource', () {
    group('getUserData', () {
      test(
        'should return UserDataResponse when cached data is present',
        () async {
          // Arrange
          when(
            () => mockLocalStorageClient.getUserSession(),
          ).thenReturn(userDataResponse.toEntity());

          // Act
          final result = await sessionLocalDataSource.getUserData();

          // Assert
          expect(result, equals(userDataResponse));
          verify(
            () => mockLocalStorageClient.getUserSession(),
          ).called(1);
        },
      );

      test('should return null when cached data is null', () async {
        // Arrange
        when(
          () => mockLocalStorageClient.getUserSession(),
        ).thenReturn(null);

        // Act
        final result = await sessionLocalDataSource.getUserData();

        // Assert
        expect(result, isNull);
        verify(
          () => mockLocalStorageClient.getUserSession(),
        ).called(1);
      });
    });

    group('saveUserData', () {
      test('should call saveUserSession with correct entity', () async {
        // Arrange
        when(
          () => mockLocalStorageClient.saveUserSession(any()),
        ).thenAnswer((_) async {});

        // Act
        await sessionLocalDataSource.saveUserData(userDataResponse);

        // Assert
        verify(
          () => mockLocalStorageClient.saveUserSession(userDataResponse.toEntity()),
        ).called(1);
      });
    });
  });
}
