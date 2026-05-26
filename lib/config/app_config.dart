import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

abstract final class Flavor {
  static const production = 'production';
  static const staging = 'staging';
  static const development = 'development';
}

/// App configuration for different app flavors.
sealed class AppConfig {
  const AppConfig({
    required this.appTitle,
    required this.apiBaseUrl,
    required this.flavor,
    required this.webBaseUrl,
  });
  final String appTitle;
  final String apiBaseUrl;
  final String flavor;

  /// The base URL for the deployed web app (e.g. https://example.web.app).
  /// Specific paths (e.g. /email-confirmation) are appended at the call site.
  final String webBaseUrl;
}

@LazySingleton(as: AppConfig, env: [Flavor.production])
final class AppConfigProd extends AppConfig {
  AppConfigProd()
    : super(
        appTitle: 'Clean Architecture App',
        apiBaseUrl: dotenv.get('SUPABASE_URL'),
        flavor: Flavor.production,
        webBaseUrl: dotenv.get('SUPABASE_BASE_URL'),
      );
}

@LazySingleton(as: AppConfig, env: [Flavor.staging])
final class AppConfigStg extends AppConfig {
  AppConfigStg()
    : super(
        appTitle: 'Clean Architecture App Staging',
        apiBaseUrl: dotenv.get('SUPABASE_URL'),
        flavor: Flavor.staging,
        webBaseUrl: dotenv.get('SUPABASE_BASE_URL'),
      );
}

@LazySingleton(as: AppConfig, env: [Flavor.development])
final class AppConfigDev extends AppConfig {
  AppConfigDev()
    : super(
        appTitle: 'Clean Architecture App Development',
        apiBaseUrl: dotenv.get('SUPABASE_URL'),
        flavor: Flavor.development,
        webBaseUrl: dotenv.get('SUPABASE_BASE_URL'),
      );
}

/// A util class for accessing [AppConfig]
abstract final class AppConfigUtil {
  /// Returns the registered instance of [AppConfig] which is always the same.
  static AppConfig get I => GetIt.I<AppConfig>();
}

/// A concrete implementation of [AppConfig] specifically for testing.
final class TestAppConfig extends AppConfig {
  const TestAppConfig({
    super.appTitle = 'Test App',
    super.apiBaseUrl = 'https://test-api.com',
    super.flavor = 'test',
    super.webBaseUrl = defaultWebBaseUrl,
  });

  /// The default base URL used in tests — exposed so tests can build expected URLs.
  static const String defaultWebBaseUrl = 'https://serviceproviders-733e7.web.app';
}

