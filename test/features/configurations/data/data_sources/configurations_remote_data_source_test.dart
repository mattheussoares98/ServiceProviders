import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/configurations/data/data_sources/configurations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/configurations/data/models/responses/configurations_response_model.dart';

import '../../../../../testing/mocks/client_mocks.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late ConfigurationsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = ConfigurationsRemoteDataSourceImpl(database: mockDatabase);
  });

  final tUserId = faker.guid.guid();
  const tResponseMap = {
    'push_notifications_enabled': true,
    'theme_mode': 'dark',
  };

  group('ConfigurationsRemoteDataSourceImpl', () {
    group('getConfigurations', () {
      test(
        'should return SuccessState<ConfigurationsResponseModel> on success',
        () async {
          when(
            () => mockDatabase.selectOne(
              table: any(named: 'table'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => tResponseMap);

          final result = await dataSource.getConfigurations(tUserId);

          expect(result, isA<SuccessState<ConfigurationsResponseModel>>());
          expect(result.data?.pushNotificationsEnabled, true);
          expect(result.data?.themeMode, 'dark');
          verify(
            () => mockDatabase.selectOne(
              table: 'user_configurations',
              filters: [SupabaseFilter.eq('user_id', tUserId)],
            ),
          ).called(1);
        },
      );

      test(
        'should return SuccessState with default configurations when no remote configuration exists',
        () async {
          when(
            () => mockDatabase.selectOne(
              table: any(named: 'table'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => null);

          final result = await dataSource.getConfigurations(tUserId);

          expect(result, isA<SuccessState<ConfigurationsResponseModel>>());
          expect(result.data?.pushNotificationsEnabled, true);
          expect(result.data?.themeMode, 'system');
        },
      );

      test('should return FailureState when DB call throws exception', () async {
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('Database error'));

        final result = await dataSource.getConfigurations(tUserId);

        expect(result, isA<FailureState<ConfigurationsResponseModel>>());
      });
    });

    group('saveConfigurations', () {
      test('should call upsert on SupabaseDatabaseClient', () async {
        when(
          () => mockDatabase.upsert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tResponseMap]);

        final result = await dataSource.saveConfigurations(
          userId: tUserId,
          pushNotificationsEnabled: true,
          themeMode: 'dark',
        );

        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockDatabase.upsert(
            table: 'user_configurations',
            values: any(
              named: 'values',
              that: isA<Map<String, dynamic>>()
                  .having((m) => m['user_id'], 'user_id', tUserId)
                  .having((m) => m['push_notifications_enabled'], 'push_notifications_enabled', true)
                  .having((m) => m['theme_mode'], 'theme_mode', 'dark'),
            ),
          ),
        ).called(1);
      });

      test('should return FailureState when DB call throws exception', () async {
        when(
          () => mockDatabase.upsert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenThrow(Exception('Database error'));

        final result = await dataSource.saveConfigurations(
          userId: tUserId,
          pushNotificationsEnabled: true,
          themeMode: 'dark',
        );

        expect(result, isA<FailureState<void>>());
      });
    });
  });
}
