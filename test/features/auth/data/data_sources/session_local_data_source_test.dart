import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/data/data_sources/session_local_data_source.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/responses/user_data_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  late MockLocalStorageClient mockLocalStorageClient;
  late SessionLocalDataSourceImpl sessionLocalDataSource;

  setUpAll(() {
    registerFallbackValue(UserDataEntity.empty());
  });

  setUp(() {
    mockLocalStorageClient = MockLocalStorageClient();
    sessionLocalDataSource = SessionLocalDataSourceImpl(mockLocalStorageClient);
  });

  final userDataResponse = UserDataModel(
    user: UserProfileModel.fromEntity(UserFactory.makeUserProfileEntity()),
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
          verify(() => mockLocalStorageClient.getUserSession()).called(1);
        },
      );

      test('should return null when cached data is null', () async {
        // Arrange
        when(() => mockLocalStorageClient.getUserSession()).thenReturn(null);

        // Act
        final result = await sessionLocalDataSource.getUserData();

        // Assert
        expect(result, isNull);
        verify(() => mockLocalStorageClient.getUserSession()).called(1);
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
          () => mockLocalStorageClient.saveUserSession(
            userDataResponse.toEntity(),
          ),
        ).called(1);
      });
    });

    group('clearSelectedMode', () {
      test('should call saveSelectedMode(null)', () async {
        // Arrange
        when(
          () => mockLocalStorageClient.saveSelectedMode(null),
        ).thenAnswer((_) async {});

        // Act
        await sessionLocalDataSource.clearSelectedMode();

        // Assert
        verify(() => mockLocalStorageClient.saveSelectedMode(null)).called(1);
      });
    });

    group('getSelectedMode', () {
      test('should call getSelectedMode on LocalStorageClient', () {
        // Arrange
        when(
          () => mockLocalStorageClient.getSelectedMode(),
        ).thenReturn('provider');

        // Act
        final result = sessionLocalDataSource.getSelectedMode();

        // Assert
        expect(result, equals('provider'));
        verify(() => mockLocalStorageClient.getSelectedMode()).called(1);
      });
    });

    group('getSelectedCompanyId', () {
      test('should call getSelectedCompanyId on LocalStorageClient', () {
        // Arrange
        when(
          () => mockLocalStorageClient.getSelectedCompanyId(),
        ).thenReturn('company_123');

        // Act
        final result = sessionLocalDataSource.getSelectedCompanyId();

        // Assert
        expect(result, equals('company_123'));
        verify(() => mockLocalStorageClient.getSelectedCompanyId()).called(1);
      });
    });

    group('saveSelectedCompanyId', () {
      test('should call saveSelectedCompanyId on LocalStorageClient', () async {
        const companyId = 'company_123';
        when(
          () => mockLocalStorageClient.saveSelectedCompanyId(any()),
        ).thenAnswer((_) async {});

        await sessionLocalDataSource.saveSelectedCompanyId(companyId);

        verify(
          () => mockLocalStorageClient.saveSelectedCompanyId(companyId),
        ).called(1);
      });
    });
  });
}
