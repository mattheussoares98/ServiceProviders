import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PlatformLauncherServiceImpl service;

  setUp(() {
    service = const PlatformLauncherServiceImpl();
  });

  group('PlatformLauncherServiceImpl - Clipboard', () {
    test('copyToClipboard copies text successfully', () async {
      String? copiedText;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'Clipboard.setData') {
              final args = methodCall.arguments as Map<dynamic, dynamic>;
              copiedText = args['text'] as String?;
              return null;
            }
            return null;
          });

      final result = await service.copyToClipboard('hello@support.com');

      expect(result.isSuccess, isTrue);
      expect(result.status, LauncherStatus.success);
      expect(copiedText, 'hello@support.com');
    });

    test('copyToClipboard returns failure when platform throws', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'Clipboard.setData') {
              throw PlatformException(
                code: 'CLIPBOARD_ERROR',
                message: 'Failed',
              );
            }
            return null;
          });

      final result = await service.copyToClipboard('fail');

      expect(result.isFailure, isTrue);
      expect(result.status, LauncherStatus.failure);
      expect(result.errorMessage, contains('CLIPBOARD_ERROR'));
    });
  });

  group('PlatformLauncherServiceImpl - launchExternalUri', () {
    test(
      'launchExternalUri returns cannotLaunch or failure on unhandled URI without plugin',
      () async {
        final result = await service.launchExternalUri(
          Uri.parse('mailto:contact@soarescodes.com.br'),
        );

        // In unit test environment without registered url_launcher channel handler,
        // it throws MissingPluginException or returns false, captured safely as failure or cannotLaunch
        expect(result.isSuccess, isFalse);
      },
    );

    test(
      'launchExternalUri returns success when url_launcher channel succeeds',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/url_launcher'),
              (MethodCall methodCall) async {
                if (methodCall.method == 'launch') {
                  return true;
                }
                if (methodCall.method == 'canLaunch') {
                  return true;
                }
                return null;
              },
            );

        final result = await service.launchExternalUri(
          Uri.parse('mailto:contact@soarescodes.com.br'),
        );

        expect(result.isSuccess, isTrue);
        expect(result.status, LauncherStatus.success);
      },
    );

    test(
      'launchExternalUri returns cannotLaunch when launch returns false',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/url_launcher'),
              (MethodCall methodCall) async {
                if (methodCall.method == 'launch') {
                  return false;
                }
                return null;
              },
            );

        final result = await service.launchExternalUri(
          Uri.parse('mailto:contact@soarescodes.com.br'),
        );

        expect(result.isCannotLaunch, isTrue);
        expect(result.status, LauncherStatus.cannotLaunch);
      },
    );
  });
}
