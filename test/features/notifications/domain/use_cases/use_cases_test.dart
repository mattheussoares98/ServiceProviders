import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/use_cases/delete_device_token_use_case.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/use_cases/register_device_token_use_case.dart';

import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockNotificationsRepository mockRepository;
  late RegisterDeviceTokenUseCase registerDeviceTokenUseCase;
  late DeleteDeviceTokenUseCase deleteDeviceTokenUseCase;

  final tDeviceToken = faker.jwt.secret;
  const tPlatform = 'android';

  setUp(() {
    mockRepository = MockNotificationsRepository();
    registerDeviceTokenUseCase = RegisterDeviceTokenUseCase(
      repository: mockRepository,
    );
    deleteDeviceTokenUseCase = DeleteDeviceTokenUseCase(
      repository: mockRepository,
    );
  });

  group('Notifications Use Cases', () {
    group('RegisterDeviceTokenUseCase', () {
      test(
        'should call repository.registerDeviceToken and return success',
        () async {
          when(
            () => mockRepository.registerDeviceToken(
              deviceToken: any(named: 'deviceToken'),
              platform: any(named: 'platform'),
            ),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await registerDeviceTokenUseCase(
            RegisterDeviceTokenParams(
              deviceToken: tDeviceToken,
              platform: tPlatform,
            ),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, true);
          verify(
            () => mockRepository.registerDeviceToken(
              deviceToken: tDeviceToken,
              platform: tPlatform,
            ),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.registerDeviceToken(
            deviceToken: any(named: 'deviceToken'),
            platform: any(named: 'platform'),
          ),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        final result = await registerDeviceTokenUseCase(
          RegisterDeviceTokenParams(
            deviceToken: tDeviceToken,
            platform: tPlatform,
          ),
        );

        expect(result, isA<FailureState<bool>>());
      });
    });

    group('DeleteDeviceTokenUseCase', () {
      test(
        'should call repository.deleteDeviceToken and return success',
        () async {
          when(
            () => mockRepository.deleteDeviceToken(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await deleteDeviceTokenUseCase(tDeviceToken);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, true);
          verify(
            () => mockRepository.deleteDeviceToken(tDeviceToken),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.deleteDeviceToken(any()),
        ).thenAnswer((_) async => FailureState(message: 'Error'));

        final result = await deleteDeviceTokenUseCase(tDeviceToken);

        expect(result, isA<FailureState<bool>>());
      });
    });
  });
}
