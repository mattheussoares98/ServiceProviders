import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/notifications/data/data_sources/notifications_remote_data_source.dart';

import '../../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late NotificationsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = NotificationsRemoteDataSourceImpl(database: mockDatabase);
  });

  final tUserId = faker.guid.guid();
  final tDeviceToken = faker.jwt.secret;
  const tPlatform = 'android';

  group('NotificationsRemoteDataSourceImpl', () {
    group('registerDeviceToken', () {
      test('should call upsert on SupabaseDatabaseClient and return SuccessState<bool>', () async {
        when(
          () => mockDatabase.upsert(
            table: any(named: 'table'),
            values: any(named: 'values'),
            onConflict: any(named: 'onConflict'),
          ),
        ).thenAnswer((_) async => []);

        final result = await dataSource.registerDeviceToken(
          userId: tUserId,
          deviceToken: tDeviceToken,
          platform: tPlatform,
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockDatabase.upsert(
            table: 'user_device_tokens',
            values: any(
              named: 'values',
              that: isA<Map<String, dynamic>>()
                  .having((m) => m['user_id'], 'user_id', tUserId)
                  .having((m) => m['device_token'], 'device_token', tDeviceToken)
                  .having((m) => m['platform'], 'platform', tPlatform),
            ),
            onConflict: 'user_id,device_token',
          ),
        ).called(1);
      });

      test('should return FailureState when DB call throws exception', () async {
        when(
          () => mockDatabase.upsert(
            table: any(named: 'table'),
            values: any(named: 'values'),
            onConflict: any(named: 'onConflict'),
          ),
        ).thenThrow(Exception('Database error'));

        final result = await dataSource.registerDeviceToken(
          userId: tUserId,
          deviceToken: tDeviceToken,
          platform: tPlatform,
        );

        expect(result, isA<FailureState<bool>>());
      });
    });

    group('deleteDeviceToken', () {
      test('should call delete on SupabaseDatabaseClient and return SuccessState<bool>', () async {
        when(
          () => mockDatabase.delete(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => []);

        final result = await dataSource.deleteDeviceToken(
          userId: tUserId,
          deviceToken: tDeviceToken,
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockDatabase.delete(
            table: 'user_device_tokens',
            filters: [
              SupabaseFilter.eq('user_id', tUserId),
              SupabaseFilter.eq('device_token', tDeviceToken),
            ],
          ),
        ).called(1);
      });

      test('should return FailureState when DB call throws exception', () async {
        when(
          () => mockDatabase.delete(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('Database error'));

        final result = await dataSource.deleteDeviceToken(
          userId: tUserId,
          deviceToken: tDeviceToken,
        );

        expect(result, isA<FailureState<bool>>());
      });
    });
  });
}
