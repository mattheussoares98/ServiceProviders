import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service.dart';

abstract interface class SupportService {
  String get supportEmail;
  bool get isEmailConfigured;
  Future<LauncherResult> launchSupportEmail({
    required String userDescription,
    required String platformName,
    String? subjectPrefix,
  });
  Future<LauncherResult> copyToClipboard(String text);
}

@LazySingleton(as: SupportService)
final class SupportServiceImpl implements SupportService {
  const SupportServiceImpl({
    required AppConfig appConfig,
    required PlatformLauncherService launcherService,
  }) : _appConfig = appConfig,
       _launcherService = launcherService;

  final AppConfig _appConfig;
  final PlatformLauncherService _launcherService;

  static final RegExp _emailRegExp = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');

  @override
  String get supportEmail => _appConfig.supportEmail.trim();

  @override
  bool get isEmailConfigured =>
      supportEmail.isNotEmpty && _emailRegExp.hasMatch(supportEmail);

  @override
  Future<LauncherResult> launchSupportEmail({
    required String userDescription,
    required String platformName,
    String? subjectPrefix,
  }) async {
    if (!isEmailConfigured) {
      return const LauncherResult.failure('unconfigured_email');
    }

    final trimmed = userDescription.trim();
    if (trimmed.isEmpty) {
      return const LauncherResult.failure('empty_description');
    }

    final prefix = subjectPrefix ?? 'Suporte';
    final subject = '[${_appConfig.appTitle}] $prefix';

    final body =
        'Descrição:\n$trimmed\n\n---\nAplicativo: ${_appConfig.appTitle}\nPlataforma: $platformName';

    final emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: {'subject': subject, 'body': body}.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&'),
    );

    return await _launcherService.launchExternalUri(emailUri);
  }

  @override
  Future<LauncherResult> copyToClipboard(String text) =>
      _launcherService.copyToClipboard(text);
}
