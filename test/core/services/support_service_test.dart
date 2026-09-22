import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service.dart';
import 'package:o_jogo_da_obra/core/services/support_service.dart';

import '../../../testing/mocks/services.dart';

void main() {
  late MockPlatformLauncherService mockLauncherService;

  setUpAll(() {
    registerFallbackValue(Uri.parse('mailto:test@example.com'));
  });

  setUp(() {
    mockLauncherService = MockPlatformLauncherService();
  });

  SupportServiceImpl buildService({
    String email = AppConfig.defaultSupportEmail,
  }) {
    return SupportServiceImpl(
      appConfig: TestAppConfig(supportEmail: email),
      launcherService: mockLauncherService,
    );
  }

  group('SupportService - email configuration', () {
    test('isEmailConfigured returns true for valid email', () {
      final service = buildService();
      expect(service.isEmailConfigured, isTrue);
      expect(service.supportEmail, 'contact@soarescodes.com.br');
    });

    test('isEmailConfigured returns false for empty or invalid email', () {
      expect(buildService(email: '').isEmailConfigured, isFalse);
      expect(buildService(email: 'invalid-email').isEmailConfigured, isFalse);
    });
  });

  group('SupportService - launchSupportEmail', () {
    test('returns failure when email is not configured', () async {
      final service = buildService(email: '');
      final result = await service.launchSupportEmail(
        userDescription: 'Help',
        platformName: 'android',
      );
      expect(result.isFailure, isTrue);
      expect(result.errorMessage, 'unconfigured_email');
    });

    test('returns failure when user description is empty', () async {
      final service = buildService();
      final result = await service.launchSupportEmail(
        userDescription: '   ',
        platformName: 'android',
      );
      expect(result.isFailure, isTrue);
      expect(result.errorMessage, 'empty_description');
    });

    test(
      'builds mailto URI with subject, body, app name, and launches',
      () async {
        final service = buildService();
        Uri? capturedUri;

        when(
          () => mockLauncherService.launchExternalUri(any<Uri>()),
        ).thenAnswer((invocation) async {
          capturedUri = invocation.positionalArguments.first as Uri;
          return const LauncherResult.success();
        });

        final result = await service.launchSupportEmail(
          userDescription: 'Preciso de ajuda com o app!',
          platformName: 'web',
        );

        expect(result.isSuccess, isTrue);
        expect(capturedUri, isNotNull);
        expect(capturedUri!.scheme, 'mailto');
        expect(capturedUri!.path, 'contact@soarescodes.com.br');
        expect(capturedUri!.queryParameters['subject'], contains('Test App'));
        expect(
          capturedUri!.queryParameters['body'],
          contains('Preciso de ajuda com o app!'),
        );
        expect(capturedUri!.queryParameters['body'], contains('web'));
      },
    );
  });

  group('SupportService - copyToClipboard', () {
    test('delegates copy to PlatformLauncherService', () async {
      final service = buildService();
      when(
        () => mockLauncherService.copyToClipboard(any<String>()),
      ).thenAnswer((_) async => const LauncherResult.success());

      final result = await service.copyToClipboard(
        'contact@soarescodes.com.br',
      );
      expect(result.isSuccess, isTrue);
      verify(
        () => mockLauncherService.copyToClipboard('contact@soarescodes.com.br'),
      ).called(1);
    });
  });
}
