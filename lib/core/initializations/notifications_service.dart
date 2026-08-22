import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/use_cases/delete_device_token_use_case.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/use_cases/register_device_token_use_case.dart';
import 'package:o_jogo_da_obra/firebase_options.dart';

/// PERFORMANCE: Using a dedicated service for notifications ensures
/// that Firebase listeners are registered exactly once and do not
/// create memory leaks during hot restarts.
class NotificationsService {
  NotificationsService._();
  static final instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// PERFORMANCE: This must be a top-level or static function.
  /// It runs in a completely separate isolate when the app is backgrounded.
  @pragma('vm:entry-point')
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    // We must re-initialize Firebase in the background isolate.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint(
      'Notifications: Background message received: ${message.messageId}',
    );
  }

  /// Sets up the notification channels and listeners.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    // 1. Request permissions (especially important for iOS and Android 13+)
    await FirebaseMessaging.instance.requestPermission();

    // 2. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // 3. Setup Foreground Listeners
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // 4. Setup Interaction Listeners (Terminated & Background)
    _setupInteractions();

    // 5. Setup Token Refresh Listener
    _setupTokenRefresh();

    // 6. Initialize Local Notifications for Android "Heads-up"
    if (!kIsWeb) {
      await _setupLocalNotifications();
    }

    _isInitialized = true;
  }

  void _setupTokenRefresh() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((token) async {
          try {
            if (GetIt.I.isRegistered<RegisterDeviceTokenUseCase>()) {
              final registerUseCase = GetIt.I<RegisterDeviceTokenUseCase>();
              await registerUseCase(
                RegisterDeviceTokenParams(
                  deviceToken: token,
                  platform: defaultTargetPlatform.name,
                ),
              );
            }
          } catch (e) {
            debugPrint('NotificationsService: Token refresh error - $e');
          }
        });
  }

  /// Sync the current device token to backend if user is authenticated.
  Future<void> syncDeviceToken() async {
    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux) {
        return;
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        if (GetIt.I.isRegistered<RegisterDeviceTokenUseCase>()) {
          final registerUseCase = GetIt.I<RegisterDeviceTokenUseCase>();
          await registerUseCase(
            RegisterDeviceTokenParams(
              deviceToken: token,
              platform: defaultTargetPlatform.name,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('NotificationsService: Failed to sync device token - $e');
    }
  }

  /// Delete current device token from backend on logout.
  Future<void> deleteDeviceToken() async {
    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux) {
        return;
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        if (GetIt.I.isRegistered<DeleteDeviceTokenUseCase>()) {
          final deleteUseCase = GetIt.I<DeleteDeviceTokenUseCase>();
          await deleteUseCase(token);
        }
      }
    } catch (e) {
      debugPrint('NotificationsService: Failed to delete device token - $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'Celta Mobile Notifications',
      description: 'Used for important system alerts.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/notification'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click here
      },
    );
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Celta Mobile Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    }
  }

  void _setupInteractions() {
    // Terminated State
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint(
          'Notifications: App opened from terminated state via: ${message.messageId}',
        );
      }
    });

    // Background State
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint(
        'Notifications: App opened from background via: ${message.messageId}',
      );
    });
  }
}
