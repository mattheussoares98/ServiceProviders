import 'dart:async';

import 'package:clean_architecture/config/app_config.dart';
import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:clean_architecture/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/cubits/keyboard_visibility/keyboard_visibility_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/session/session_cubit.dart';
import 'package:clean_architecture/shared_ui/themes/theme.dart';
import 'package:clean_architecture/shared_ui/utils/screen_util/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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
  late final SessionCubit _sessionCubit;
  late final UsersCubit _usersCubit;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _screenObserverCubit = GetIt.I<ScreenObserverCubit>();
    _keyboardVisibilityCubit = GetIt.I<KeyboardVisibilityCubit>();
    _configurationsCubit = GetIt.I<ConfigurationsCubit>();
    _sessionCubit = GetIt.I<SessionCubit>();
    _usersCubit = GetIt.I<UsersCubit>()..loadAll();
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => InternetUtil.I.subscribeConnectivity(),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _screenObserverCubit.close();
    _keyboardVisibilityCubit.close();
    _configurationsCubit.close();
    _sessionCubit.close();
    _usersCubit.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
        BlocProvider.value(value: _sessionCubit),
        BlocProvider.value(value: _usersCubit),
      ],
      child: BlocBuilder<ConfigurationsCubit, ConfigurationsState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: AppConfigUtil.I.appTitle,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: state.themeMode,
            routerDelegate: NavigationUtil.I.routerDelegate,
            routeInformationParser: NavigationUtil.I.routeInformationParser,
          );
        },
      ),
    );
  }
}
