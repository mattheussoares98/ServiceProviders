import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

/// Overrides [HttpOverrides] to permit real HTTPS network traffic to Supabase
/// within Flutter widget test bindings.
class LiveHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 30);
  }
}

/// Helper for executing widget tests with real Supabase network connections.
class LiveUiTestHelper {
  const LiveUiTestHelper._();

  /// Sets up real network connections and desktop-resolution test viewports.
  static void configureLiveTestEnvironment(WidgetTester tester) {
    HttpOverrides.global = LiveHttpOverrides();
    addTearDown(() {
      HttpOverrides.global = null;
    });

    tester.view.physicalSize = const Size(1920, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const screenDetails = ScreenDetails(
      logicalSize: Size(1920, 1280),
      physicalSize: Size(1920, 1280),
      devicePixelRatio: 1,
    );
    ScreenUtil.I.configureScreen(screenDetails);
  }

  /// Sets up [GetSelectedModeUseCase] in [GetIt] with the requested [activeMode].
  static void configureAppMode(AppMode activeMode) {
    if (GetIt.I.isRegistered<GetSelectedModeUseCase>()) {
      GetIt.I.unregister<GetSelectedModeUseCase>();
    }
    GetIt.I.registerLazySingleton<GetSelectedModeUseCase>(
      () => _StaticGetSelectedModeUseCase(activeMode),
    );
    addTearDown(() {
      if (GetIt.I.isRegistered<GetSelectedModeUseCase>()) {
        GetIt.I.unregister<GetSelectedModeUseCase>();
      }
    });
  }
}

class _StaticGetSelectedModeUseCase implements GetSelectedModeUseCase {
  const _StaticGetSelectedModeUseCase(this._mode);
  final AppMode _mode;

  @override
  String call() => _mode.name;
}
