import 'dart:convert';

import 'package:clean_architecture/core/constants/local_db_keys.dart';
import 'package:clean_architecture/core/data/models/responses/user_model.dart';
import 'package:clean_architecture/features/auth/data/data_sources/session_local_data_source.dart';
import 'package:clean_architecture/features/auth/data/models/responses/user_data_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/helpers/test_factory.dart';
import '../../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockLocalStorageClient mockLocalStorageClient;
  late SessionLocalDataSourceImpl sessionLocalDataSource;

  setUp(() {
    mockLocalStorageClient = MockLocalStorageClient();
    sessionLocalDataSource = SessionLocalDataSourceImpl(mockLocalStorageClient);
  });

  final userDataResponse = UserDataResponseModel(
    user: UserModel.fromEntity(TestFactory.makeUserEntity()),
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
            () =>
                mockLocalStorageClient.getEncryptedString(LocalDbKeys.userData),
          ).thenReturn(jsonEncode(userDataResponse.toJson()));

          // Act
          final result = await sessionLocalDataSource.getUserData();

          // Assert
          expect(result, equals(userDataResponse));
          verify(
            () =>
                mockLocalStorageClient.getEncryptedString(LocalDbKeys.userData),
          ).called(1);
        },
      );

      test('should return null when cached data is empty', () async {
        // Arrange
        when(
          () => mockLocalStorageClient.getEncryptedString(LocalDbKeys.userData),
        ).thenReturn('');

        // Act
        final result = await sessionLocalDataSource.getUserData();

        // Assert
        expect(result, isNull);
      });

      test('should return null when cached data is null', () async {
        // Arrange
        when(
          () => mockLocalStorageClient.getEncryptedString(LocalDbKeys.userData),
        ).thenReturn(null);

        // Act
        final result = await sessionLocalDataSource.getUserData();

        // Assert
        expect(result, isNull);
      });

      test(
        'should return null (catch error) when cached data is invalid json',
        () async {
          // Arrange
          when(
            () =>
                mockLocalStorageClient.getEncryptedString(LocalDbKeys.userData),
          ).thenReturn('invalid json');

          // Act
          final result = await sessionLocalDataSource.getUserData();

          // Assert
          expect(result, isNull);
        },
      );
    });

    group('saveUserData', () {
      test(
        'should call setStringWithEncryption with correct key and value',
        () async {
          // Arrange
          when(
            () => mockLocalStorageClient.setStringWithEncryption(any(), any()),
          ).thenAnswer((_) async => true);

          // Act
          await sessionLocalDataSource.saveUserData(userDataResponse);

          // Assert
          verify(
            () => mockLocalStorageClient.setStringWithEncryption(
              LocalDbKeys.userData,
              jsonEncode(userDataResponse.toJson()),
            ),
          ).called(1);
        },
      );
    });

    group('clearUserData', () {
      test('should call remove with correct key', () async {
        // Arrange
        when(
          () => mockLocalStorageClient.remove(any()),
        ).thenAnswer((_) async => true);

        // Act
        await sessionLocalDataSource.clearUserData();

        // Assert
        verify(
          () => mockLocalStorageClient.remove(LocalDbKeys.userData),
        ).called(1);
      });
    });
  });
}
