import 'package:clean_architecture/config/app_config.dart';
import 'package:clean_architecture/core/initializations/app_initializer.dart';
import 'package:clean_architecture/shared_ui/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  // Must be set before any Flutter engine code to ensure the initial URL path
  // is read correctly on web (e.g. /email-confirmation deep links).
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initializeApp(environment: Flavor.production);

  runApp(const CleanArchitectureSample());
}
