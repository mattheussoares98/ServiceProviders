import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/keyboard_visibility/keyboard_visibility_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/themes/theme.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/offline_advisory_listener.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final ScreenObserverCubit _screenObserverCubit;
  late final KeyboardVisibilityCubit _keyboardVisibilityCubit;
  late final ConfigurationsCubit _configurationsCubit;
  late final OfflineAdvisoryCubit _offlineAdvisoryCubit;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _screenObserverCubit = GetIt.I<ScreenObserverCubit>();
    _keyboardVisibilityCubit = GetIt.I<KeyboardVisibilityCubit>();
    _configurationsCubit = GetIt.I<ConfigurationsCubit>()..loadConfigurations();
    _offlineAdvisoryCubit = GetIt.I<OfflineAdvisoryCubit>();

    GetIt.I<OfflineTracker>().init();

    WidgetsBinding.instance.addObserver(this);

    // Listen for Supabase Auth state changes (specifically for password recovery redirect)
    _authSubscription = GetIt.I<SupabaseAuthClient>().onAuthStateChange.listen((
      data,
    ) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        NavigationUtil.I.replaceAllRoute(const ChangePasswordRoute());
      }
    });

    // Listen for internet connectivity changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InternetUtil.I.subscribeConnectivity();
      _offlineAdvisoryCubit.checkStartupOrResume();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _screenObserverCubit.close();
    _keyboardVisibilityCubit.close();
    _configurationsCubit.close();
    _offlineAdvisoryCubit.close();
    GetIt.I<OfflineTracker>().dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _offlineAdvisoryCubit.checkStartupOrResume();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Schedule the screen size update to happen after the current frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Don't update if this context is already unmounted.
      if (mounted) {
        _screenObserverCubit.update();
        if (PlatformUtil.isIOS) {
          _keyboardVisibilityCubit.update();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Perform initial configuration.
    ScreenUtil.I.configureScreen();
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _screenObserverCubit),
        BlocProvider.value(value: _keyboardVisibilityCubit),
        BlocProvider.value(value: _configurationsCubit),
        BlocProvider.value(value: _offlineAdvisoryCubit),
      ],
      child: BlocBuilder<ConfigurationsCubit, ConfigurationsState>(
        builder: (context, state) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: MaterialApp.router(
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('pt', 'BR')],
              locale: const Locale('pt', 'BR'), // Forces PT/BR as default
              debugShowCheckedModeBanner: false,
              title: AppConfigUtil.I.appTitle,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: state.themeMode,
              routerDelegate: NavigationUtil.I.routerDelegate,
              routeInformationParser: NavigationUtil.I.routeInformationParser,
              builder: (context, child) => OfflineAdvisoryListener(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}
