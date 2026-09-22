import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_channel_entity.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_channel_type.dart';
import 'package:o_jogo_da_obra/features/support/domain/entities/support_draft_message_entity.dart';
import 'package:o_jogo_da_obra/features/support/domain/use_cases/copy_support_text_use_case.dart';
import 'package:o_jogo_da_obra/features/support/domain/use_cases/get_support_channels_use_case.dart';
import 'package:o_jogo_da_obra/features/support/domain/use_cases/launch_support_channel_use_case.dart';
import 'package:o_jogo_da_obra/features/support/domain/use_cases/prepare_support_draft_use_case.dart';

import '../../../../../testing/mocks/factories/support_factory.dart';
import '../../../../../testing/mocks/services.dart';

void main() {
  late MockPlatformLauncherService mockLauncherService;

  setUpAll(() {
    registerFallbackValue(Uri.parse('mailto:test@example.com'));
  });

  setUp(() {
    mockLauncherService = MockPlatformLauncherService();
  });

  group('GetSupportChannelsUseCase', () {
    test('returns available email channel when configured validly', () async {
      const config = TestAppConfig();
      const useCase = GetSupportChannelsUseCase(appConfig: config);

      final result = await useCase();

      expect(result, isA<SuccessState<List<SupportChannelEntity>>>());
      final channels =
          (result as SuccessState<List<SupportChannelEntity>>).data!;
      expect(channels.length, 1);
      expect(channels.first.type, SupportChannelType.email);
      expect(channels.first.destination, 'contact@soarescodes.com.br');
      expect(channels.first.isAvailable, isTrue);
      expect(channels.first.unavailableReason, isNull);
    });

    test('returns unavailable channel when support email is empty', () async {
      const config = TestAppConfig(supportEmail: '');
      const useCase = GetSupportChannelsUseCase(appConfig: config);

      final result = await useCase();

      expect(result, isA<SuccessState<List<SupportChannelEntity>>>());
      final channels =
          (result as SuccessState<List<SupportChannelEntity>>).data!;
      expect(channels.length, 1);
      expect(channels.first.isAvailable, isFalse);
      expect(channels.first.unavailableReason, 'unconfigured_email');
    });

    test(
      'returns unavailable channel when support email format is invalid',
      () async {
        const config = TestAppConfig(supportEmail: 'invalid-email');
        const useCase = GetSupportChannelsUseCase(appConfig: config);

        final result = await useCase();

        expect(result, isA<SuccessState<List<SupportChannelEntity>>>());
        final channels =
            (result as SuccessState<List<SupportChannelEntity>>).data!;
        expect(channels.length, 1);
        expect(channels.first.isAvailable, isFalse);
        expect(channels.first.unavailableReason, 'invalid_email');
      },
    );
  });

  group('PrepareSupportDraftUseCase', () {
    const useCase = PrepareSupportDraftUseCase();

    test(
      'prepares support draft with correct formatting, app name, and platform',
      () async {
        final params = SupportFactory.makePrepareSupportDraftParams(
          userDescription: 'Preciso de ajuda com a sincronização.',
          appName: 'O Jogo da Obra',
          platformName: 'android',
          subjectPrefix: 'Dúvida',
        );

        final result = await useCase(params);

        expect(result, isA<SuccessState<SupportDraftMessageEntity>>());
        final draft = (result as SuccessState<SupportDraftMessageEntity>).data!;
        expect(draft.destination, 'contact@soarescodes.com.br');
        expect(draft.subject, '[O Jogo da Obra] Dúvida');
        expect(
          draft.body,
          contains('Descrição:\nPreciso de ajuda com a sincronização.'),
        );
        expect(draft.body, contains('Aplicativo: O Jogo da Obra'));
        expect(draft.body, contains('Plataforma: android'));
      },
    );

    test(
      'retains special characters, line breaks, ampersands, and unicode in description',
      () async {
        const specialText =
            'Erro ao salvar: & < > + " \' # % 🚀\nSegunda linha com acentuação: ação, café.';
        final params = SupportFactory.makePrepareSupportDraftParams(
          userDescription: specialText,
        );

        final result = await useCase(params);

        expect(result, isA<SuccessState<SupportDraftMessageEntity>>());
        final draft = (result as SuccessState<SupportDraftMessageEntity>).data!;
        expect(draft.body, contains(specialText));
      },
    );

    test(
      'returns FailureState when description is empty or whitespace only',
      () async {
        final params = SupportFactory.makePrepareSupportDraftParams(
          userDescription: '   \n  ',
        );

        final result = await useCase(params);

        expect(result, isA<FailureState<SupportDraftMessageEntity>>());
        expect(result.message, 'empty_description');
      },
    );

    test(
      'returns FailureState when description exceeds maximum length',
      () async {
        final longText = 'a' * 2001;
        final params = SupportFactory.makePrepareSupportDraftParams(
          userDescription: longText,
        );

        final result = await useCase(params);

        expect(result, isA<FailureState<SupportDraftMessageEntity>>());
        expect(result.message, 'description_too_long');
      },
    );
  });

  group('LaunchSupportChannelUseCase', () {
    late LaunchSupportChannelUseCase useCase;

    setUp(() {
      useCase = LaunchSupportChannelUseCase(
        platformLauncherService: mockLauncherService,
      );
    });

    test('returns SuccessState when platform launch succeeds', () async {
      final draft = SupportFactory.makeSupportDraftMessageEntity();

      when(
        () => mockLauncherService.launchExternalUri(any()),
      ).thenAnswer((_) async => const LauncherResult.success());

      final result = await useCase(draft);

      expect(result, isA<SuccessState<LauncherResult>>());
      verify(
        () => mockLauncherService.launchExternalUri(any(that: isA<Uri>())),
      ).called(1);
    });

    test(
      'returns FailureState when platform launch returns cannotLaunch',
      () async {
        final draft = SupportFactory.makeSupportDraftMessageEntity();

        when(
          () => mockLauncherService.launchExternalUri(any()),
        ).thenAnswer((_) async => const LauncherResult.cannotLaunch());

        final result = await useCase(draft);

        expect(result, isA<FailureState<LauncherResult>>());
        expect(result.message, 'cannot_launch');
      },
    );

    test('returns FailureState when platform launch throws or fails', () async {
      final draft = SupportFactory.makeSupportDraftMessageEntity();

      when(
        () => mockLauncherService.launchExternalUri(any()),
      ).thenAnswer((_) async => const LauncherResult.failure('No app found'));

      final result = await useCase(draft);

      expect(result, isA<FailureState<LauncherResult>>());
      expect(result.message, 'launch_failed');
      expect(result.error, 'No app found');
    });
  });

  group('CopySupportTextUseCase', () {
    late CopySupportTextUseCase useCase;

    setUp(() {
      useCase = CopySupportTextUseCase(
        platformLauncherService: mockLauncherService,
      );
    });

    test('returns SuccessState when copy succeeds', () async {
      when(
        () => mockLauncherService.copyToClipboard(any()),
      ).thenAnswer((_) async => const LauncherResult.success());

      final result = await useCase('contact@soarescodes.com.br');

      expect(result, isA<SuccessState<LauncherResult>>());
      verify(
        () => mockLauncherService.copyToClipboard('contact@soarescodes.com.br'),
      ).called(1);
    });

    test('returns FailureState when copy fails', () async {
      when(() => mockLauncherService.copyToClipboard(any())).thenAnswer(
        (_) async => const LauncherResult.failure('Clipboard unavailable'),
      );

      final result = await useCase('contact@soarescodes.com.br');

      expect(result, isA<FailureState<LauncherResult>>());
      expect(result.message, 'copy_failed');
      expect(result.error, 'Clipboard unavailable');
    });
  });
}
