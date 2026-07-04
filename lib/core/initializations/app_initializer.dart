import 'package:clean_architecture/config/injector/injector.dart';
import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/initializations/notifications_initialization.dart';
import 'package:clean_architecture/features/auth/domain/repositories/session_repository.dart';
import 'package:clean_architecture/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class AppInitializer {
  static Future<void> initializeApp({required String environment}) async {
    await ErrorHandler.executeSafe(() async {
      await dotenv.load();

      Intl.defaultLocale = 'pt_BR';
      await initializeDateFormatting('pt_BR');

      await Future.wait([_initFirebase(), _initSupabase()]);
      await configureDependencies(environment: environment);

      final sessionRepo = GetIt.I<SessionRepository>();
      await sessionRepo.checkForUserCredential();
    });
  }

  static Future<void> _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        kIsWeb) {
      return;
    }
    // Initialize Crashlytics (Non-web only)
    if (!kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    // Initialize Notifications Service
    await NotificationsService.instance
        .initialize()
        .then((_) {
          debugPrint('Notifications: Async Init Complete');
        })
        .catchError((Object e) {
          debugPrint('Notifications Error: Async Init Failed - $e');
        });
  }

  static Future<void> _initSupabase() async {
    try {
      await Supabase.initialize(
        url: dotenv.get('SUPABASE_URL'),
        publishableKey: dotenv.get('SUPABASE_ANON_KEY'),
      );
    } catch (e, stackTrace) {
      debugPrint('Supabase initialization warning/error: $e');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}
