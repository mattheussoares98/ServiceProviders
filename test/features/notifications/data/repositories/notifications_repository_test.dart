import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/notifications/data/repositories/notifications_repository_impl.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockInternetClient mockInternet;
  late MockNotificationsRemoteDataSource mockRemoteDataSource;
  late MockSessionRepository mockSessionRepository;
  late NotificationsRepositoryImpl repository;

  final tUser = EntityFactory.makeUserDataEntity();
  final tDeviceToken = faker.jwt.secret;
  const tPlatform = 'android';

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockNotificationsRemoteDataSource();
    mockSessionRepository = MockSessionRepository();
    repository = NotificationsRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      sessionRepository: mockSessionRepository,
    );
  });

  group('NotificationsRepositoryImpl', () {
    group('registerDeviceToken', () {
      test(
        'should register token remotely when internet is connected and user is logged in',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(() => mockSessionRepository.userData).thenReturn(tUser);
          when(
            () => mockRemoteDataSource.registerDeviceToken(
              userId: any(named: 'userId'),
              deviceToken: any(named: 'deviceToken'),
              platform: any(named: 'platform'),
            ),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.registerDeviceToken(
            deviceToken: tDeviceToken,
            platform: tPlatform,
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, true);
          verify(
            () => mockRemoteDataSource.registerDeviceToken(
              userId: tUser.user.id,
              deviceToken: tDeviceToken,
              platform: tPlatform,
            ),
          ).called(1);
        },
      );

      test(
        'should return FailureState when user is not authenticated',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(() => mockSessionRepository.userData).thenReturn(
            EntityFactory.makeUserDataEntity().copyWith(
              user: EntityFactory.makeUserDataEntity().user.copyWith(id: ''),
            ),
          );
          when(() => mockSessionRepository.currentAuthUser).thenReturn(null);

          final result = await repository.registerDeviceToken(
            deviceToken: tDeviceToken,
            platform: tPlatform,
          );

          expect(result, isA<FailureState<bool>>());
          verifyNever(
            () => mockRemoteDataSource.registerDeviceToken(
              userId: any(named: 'userId'),
              deviceToken: any(named: 'deviceToken'),
              platform: any(named: 'platform'),
            ),
          );
        },
      );

      test(
        'should return FailureState when remote data source fails',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(() => mockSessionRepository.userData).thenReturn(tUser);
          when(
            () => mockRemoteDataSource.registerDeviceToken(
              userId: any(named: 'userId'),
              deviceToken: any(named: 'deviceToken'),
              platform: any(named: 'platform'),
            ),
          ).thenAnswer((_) async => FailureState(message: 'Error'));

          final result = await repository.registerDeviceToken(
            deviceToken: tDeviceToken,
            platform: tPlatform,
          );

          expect(result, isA<FailureState<bool>>());
        },
      );
    });

    group('deleteDeviceToken', () {
      test(
        'should delete token remotely when internet is connected and user is logged in',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(() => mockSessionRepository.userData).thenReturn(tUser);
          when(
            () => mockRemoteDataSource.deleteDeviceToken(
              userId: any(named: 'userId'),
              deviceToken: any(named: 'deviceToken'),
            ),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.deleteDeviceToken(tDeviceToken);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, true);
          verify(
            () => mockRemoteDataSource.deleteDeviceToken(
              userId: tUser.user.id,
              deviceToken: tDeviceToken,
            ),
          ).called(1);
        },
      );

      test(
        'should return FailureState when user is not authenticated',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(() => mockSessionRepository.userData).thenReturn(
            EntityFactory.makeUserDataEntity().copyWith(
              user: EntityFactory.makeUserDataEntity().user.copyWith(id: ''),
            ),
          );
          when(() => mockSessionRepository.currentAuthUser).thenReturn(null);

          final result = await repository.deleteDeviceToken(tDeviceToken);

          expect(result, isA<FailureState<bool>>());
          verifyNever(
            () => mockRemoteDataSource.deleteDeviceToken(
              userId: any(named: 'userId'),
              deviceToken: any(named: 'deviceToken'),
            ),
          );
        },
      );

      test(
        'should return FailureState when remote data source fails',
        () async {
          when(() => mockInternet.isConnected).thenReturn(true);
          when(() => mockSessionRepository.userData).thenReturn(tUser);
          when(
            () => mockRemoteDataSource.deleteDeviceToken(
              userId: any(named: 'userId'),
              deviceToken: any(named: 'deviceToken'),
            ),
          ).thenAnswer((_) async => FailureState(message: 'Error'));

          final result = await repository.deleteDeviceToken(tDeviceToken);

          expect(result, isA<FailureState<bool>>());
        },
      );
    });
  });
}
