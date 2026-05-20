import 'package:clean_architecture/config/app_config.dart';
import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:clean_architecture/routing/helper/navigation_client.dart';
import 'package:clean_architecture/shared_ui/cubits/keyboard_visibility/keyboard_visibility_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/screen_observer/screen_observer_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/theme/theme_cubit.dart';
import 'package:clean_architecture/shared_ui/themes/theme.dart';
import 'package:clean_architecture/shared_ui/utils/screen_util/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class CleanArchitectureSample extends StatefulWidget {
  const CleanArchitectureSample({super.key});

  @override
  State<CleanArchitectureSample> createState() =>
      _CleanArchitectureSampleState();
}

class _CleanArchitectureSampleState extends State<CleanArchitectureSample>
    with WidgetsBindingObserver {
  late final ScreenObserverCubit _screenObserverCubit;
  late final KeyboardVisibilityCubit _keyboardVisibilityCubit;
  late final ThemeCubit _themeCubit;

  @override
  void initState() {
    super.initState();
    _screenObserverCubit = GetIt.I<ScreenObserverCubit>();
    _keyboardVisibilityCubit = GetIt.I<KeyboardVisibilityCubit>();
    _themeCubit = GetIt.I<ThemeCubit>();
    WidgetsBinding.instance.addObserver(this);
    // Listen for internet connectivity changes.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => InternetUtil.I.subscribeConnectivity(),
    );
  }

  @override
  void dispose() {
    _screenObserverCubit.close();
    _keyboardVisibilityCubit.close();
    _themeCubit.close();
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
        BlocProvider.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: AppConfigUtil.I.appTitle,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeState.themeMode,
            routerDelegate: NavigationUtil.I.routerDelegate,
            routeInformationParser: NavigationUtil.I.routeInformationParser,
          );
        },
      ),
    );
  }
}
