import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/services/platform_launcher_service.dart';
import 'package:url_launcher/url_launcher.dart';

@LazySingleton(as: PlatformLauncherService)
final class PlatformLauncherServiceImpl implements PlatformLauncherService {
  const PlatformLauncherServiceImpl();

  @override
  Future<LauncherResult> launchExternalUri(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        return const LauncherResult.success();
      }
      return const LauncherResult.cannotLaunch();
    } catch (e) {
      return LauncherResult.failure(e.toString());
    }
  }

  @override
  Future<LauncherResult> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return const LauncherResult.success();
    } catch (e) {
      return LauncherResult.failure(e.toString());
    }
  }
}
