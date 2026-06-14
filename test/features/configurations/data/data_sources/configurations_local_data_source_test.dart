import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/configurations/data/data_sources/configurations_local_data_source.dart';
import 'package:clean_architecture/features/configurations/domain/entities/configurations_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockLocalStorageClient mockLocalStorageClient;
  late ConfigurationsLocalDataSourceImpl dataSource;

  setUp(() {
    mockLocalStorageClient = MockLocalStorageClient();
    dataSource = ConfigurationsLocalDataSourceImpl(
      localDatabase: mockLocalStorageClient,
    );
  });

  group('getConfigurations', () {
    test(
      'should return SuccessState containing ConfigurationsEntity from LocalStorageClient',
      () async {
        final tPushEnabled = faker.randomGenerator.boolean();
        final tThemeMode = faker.randomGenerator.element([
          'light',
          'dark',
          'system',
        ]);

        when(
          () => mockLocalStorageClient.getPushNotifications(),
        ).thenReturn(tPushEnabled);
        when(
          () => mockLocalStorageClient.getThemeMode(),
        ).thenReturn(tThemeMode);

        final result = await dataSource.getConfigurations();

        expect(result, isA<SuccessState<ConfigurationsEntity>>());
        final entity = (result as SuccessState<ConfigurationsEntity>).data;
        expect(entity?.pushNotificationsEnabled, tPushEnabled);
        expect(entity?.themeMode, tThemeMode);
        expect(entity?.systemNotificationsEnabled, false);
        verify(() => mockLocalStorageClient.getPushNotifications()).called(1);
        verify(() => mockLocalStorageClient.getThemeMode()).called(1);
      },
    );

    test('should return FailureState when an error occurs', () async {
      when(
        () => mockLocalStorageClient.getPushNotifications(),
      ).thenThrow(Exception('Storage error'));

      final result = await dataSource.getConfigurations();

      expect(result, isA<FailureState<ConfigurationsEntity>>());
    });
  });

  group('savePushNotifications', () {
    test('should call savePushNotifications on LocalStorageClient', () async {
      final tEnabled = faker.randomGenerator.boolean();
      when(
        () => mockLocalStorageClient.savePushNotifications(tEnabled),
      ).thenAnswer((_) async {});

      final result = await dataSource.savePushNotifications(tEnabled);

      expect(result, const SuccessState(data: true));
      verify(
        () => mockLocalStorageClient.savePushNotifications(tEnabled),
      ).called(1);
    });

    test('should return FailureState when saving throws error', () async {
      final tEnabled = faker.randomGenerator.boolean();
      when(
        () => mockLocalStorageClient.savePushNotifications(tEnabled),
      ).thenThrow(Exception('Save error'));

      final result = await dataSource.savePushNotifications(tEnabled);

      expect(result, isA<FailureState<bool>>());
    });
  });
}
