import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:clean_architecture/features/auth/presentation/pages/login/widgets/login_button.dart';
import 'package:clean_architecture/features/auth/presentation/pages/login/widgets/login_form.dart';
import 'package:clean_architecture/features/auth/presentation/widgets/welcome_logo.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class LoginPage extends HookWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    return BlocProvider(
      create: (context) => GetIt.I<LoginCubit>()
        // Clear any stale session data when login page loads
        // This ensures fresh state after auth interceptor logout
        ..clearSession(),
      child: Builder(
        builder: (context) {
          return BaseScaffold(
            observeScreenChanges: true,
            showAnnotatedRegion: true,
            body: Column(
              children: [
                gapH24,
                WelcomeLogo(title: 'Login'.hardcoded),
                gapH12,
                Form(
                  key: formKey,
                  child: LoginForm(
                    usernameController: usernameController,
                    passwordController: passwordController,
                  ),
                ),
                gapH32,
                LoginButton(
                  formKey: formKey,
                  usernameController: usernameController,
                  passwordController: passwordController,
                ),
                gapH16,
                TextButton(
                  onPressed: context.read<LoginCubit>().navigateToSignUp,
                  child: Text('Criar conta'.hardcoded),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
