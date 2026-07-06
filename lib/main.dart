import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';
import 'package:o_jogo_da_obra/core/initializations/app_initializer.dart';
import 'package:o_jogo_da_obra/shared_ui/my_app.dart';

Future<void> main() async {
  // Must be set before any Flutter engine code to ensure the initial URL path
  // is read correctly on web (e.g. /email-confirmation deep links).
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initializeApp(environment: Flavor.production);

  runApp(const MyApp());
}
